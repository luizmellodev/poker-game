//
//  PokerGame.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import SwiftUI

class PokerGame: ObservableObject {
    @Published var currentRaiseAmount: Int
    @Published var deck: [Card] = []
    @Published var players: [Player] = []
    @Published var communityCards: [Card] = []
    @Published var pot: Int = 0
    @Published var currentBet: Int = 0
    @Published var currentPlayerIndex: Int = 0
    @Published var gameStage: GameStage = .preFlop
    @Published var roundActions: [GameAction] = []
    @Published var isGameFinished: Bool = false
    @Published var winningHand: [Card]?
    @Published var winner: Player?
    @Published var showingLowChipsAlert = false
    @Published var thinkingPlayerIndex: Int?
    
    private var actionCounter = 0
    
    private let gameSettings = GameSettings.shared
    
    var currentPlayer: Player {
        return players[currentPlayerIndex]
    }
    
    init() {
        self.currentRaiseAmount = gameSettings.defaultRaiseAmount
        resetGame()
    }
    
    func resetGame() {
        // Save current chips to settings before reset
        if let existingPlayer = players.first(where: { $0.name == "You" }) {
            gameSettings.updatePlayerChips(existingPlayer.chips)
        }
        
        if gameSettings.playerChips < 50 {
            showingLowChipsAlert = true
            return
        }
        
        currentRaiseAmount = gameSettings.defaultRaiseAmount
        
        deck = generateDeck()
        
        var allPlayers = [Player(name: "You", chips: gameSettings.playerChips)]
        allPlayers.append(contentsOf: gameSettings.bots.map { bot in
            Player(name: bot.name, chips: 1000)
        })
        
        players = allPlayers
        communityCards = []
        pot = 0
        currentBet = 0
        currentPlayerIndex = 0
        roundActions = []
        gameStage = .preFlop
        isGameFinished = false
        winningHand = nil
        dealCards()
    }
    
    func updatePlayerChips() {
        if let player = players.first(where: { $0.name == "You" }) {
            gameSettings.updatePlayerChips(player.chips)
        }
    }
    
    func generateDeck() -> [Card] {
        let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        let suits = ["♠", "♥", "♦", "♣"]
        
        var deck: [Card] = []
        for suit in suits {
            for rank in ranks {
                deck.append(Card(rank: rank, suit: suit))
            }
        }
        deck.shuffle()
        return deck
    }
    
    func dealCards() {
        for i in 0..<players.count {
            players[i].hand = [deck.removeFirst(), deck.removeFirst()]
        }
    }
    
    func flop() {
        communityCards.append(contentsOf: [deck.removeFirst(), deck.removeFirst(), deck.removeFirst()])
        gameStage = .flop
    }
    
    func turn() {
        communityCards.append(deck.removeFirst())
        gameStage = .turn
    }
    
    func river() {
        communityCards.append(deck.removeFirst())
        gameStage = .river
    }
    
    func nextTurn() {
        guard !players.isEmpty else { return }
        
        // Se todos menos um jogador deram fold, determina o vencedor
        if allPlayersButOneFolded() {
            determineWinner()
            return
        }
        
        // Avança para o próximo jogador que não deu fold
        repeat {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        } while players[currentPlayerIndex].isFolded && !isGameFinished
        
        if currentPlayer.name != "You" {
            // Set thinking state and play turn sound
            withAnimation {
                thinkingPlayerIndex = currentPlayerIndex
            }
            SoundManager.shared.playTurnChange()
            
            // Add delay before bot action
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.performBotAction(for: self.currentPlayer)
                
                // Add delay after bot action before next turn
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        self.thinkingPlayerIndex = nil
                    }
                    self.nextTurn()
                }
            }
        } else {
            // When it's player's turn
            SoundManager.shared.playTurnChange()
            thinkingPlayerIndex = nil
        }
        
        if (currentPlayerIndex == 0 || (players[0].isFolded && currentPlayerIndex == 1)) && !allPlayersButOneFolded() {
            switch gameStage {
            case .preFlop:
                flop()
            case .flop:
                turn()
            case .turn:
                river()
            case .river, .showdown:
                determineWinner()
            }
        }
    }
    
    func performBotAction(for player: Player) {
        // Skip if player has no chips for betting
        if player.chips <= 0 {
            player.currentAction = .check
            addAction("\(player.name) has no chips and checks")
            return
        }

        let handEvaluation = evaluateHand(for: player)
        let handStrength = handEvaluation.0
        let callAmount = currentBet
        let potOdds = Double(callAmount) / Double(pot + callAmount)
        
        // Adjust bluff probability based on difficulty
        let bluffProbability: Double
        switch gameSettings.gameDifficulty {
        case .easy:
            bluffProbability = 0.1
        case .medium:
            bluffProbability = 0.2
        case .hard:
            bluffProbability = 0.3
        }
        
        let shouldBluff = Double.random(in: 0...1) < bluffProbability
        
        switch gameStage {
        case .preFlop:
            handlePreFlopDecision(player: player, handStrength: handStrength, callAmount: callAmount, shouldBluff: shouldBluff)
        case .flop, .turn, .river:
            handlePostFlopDecision(player: player, handStrength: handStrength, callAmount: callAmount, potOdds: potOdds, shouldBluff: shouldBluff)
        case .showdown:
            break
        }
    }

    private func handlePreFlopDecision(player: Player, handStrength: Int, callAmount: Int, shouldBluff: Bool) {
        let hasPairOrBetter = handStrength >= 2
        let hasHighCard = player.hand.contains { $0.rank == "A" || $0.rank == "K" || $0.rank == "Q" }
        
        // Calculate raise amount based on difficulty
        let baseRaiseAmount: Int
        let raiseChance: Double
        
        switch gameSettings.gameDifficulty {
        case .easy:
            baseRaiseAmount = 30
            raiseChance = 0.3
        case .medium:
            baseRaiseAmount = 50
            raiseChance = 0.5
        case .hard:
            baseRaiseAmount = 70
            raiseChance = 0.7
        }
        
        // Calculate max possible raise based on available chips
        let maxPossibleBet = min(player.chips, currentBet + baseRaiseAmount)
        
        if hasPairOrBetter || hasHighCard || shouldBluff {
            if callAmount == 0 {
                if player.chips >= baseRaiseAmount && Double.random(in: 0...1) < raiseChance {
                    let raiseAmount = min(baseRaiseAmount, player.chips - currentBet)
                    if raiseAmount > 0 {
                        player.currentAction = .raise(raiseAmount)
                        player.chips -= (currentBet + raiseAmount)
                        pot += (currentBet + raiseAmount)
                        currentBet += raiseAmount
                        addAction("\(player.name) raised to \(currentBet)")
                        return
                    }
                }
                player.currentAction = .check
                addAction("\(player.name) checked")
            } else if callAmount <= maxPossibleBet {
                // Fold chance based on difficulty when facing a bet
                let foldChance: Double
                switch gameSettings.gameDifficulty {
                case .easy:
                    foldChance = 0.4
                case .medium:
                    foldChance = 0.3
                case .hard:
                    foldChance = 0.2
                }
                
                if Double.random(in: 0...1) < foldChance {
                    player.currentAction = .fold
                    player.isFolded = true
                    addAction("\(player.name) folded")
                } else {
                    player.chips -= callAmount
                    pot += callAmount
                    player.currentAction = .call
                    addAction("\(player.name) called \(callAmount)")
                }
            } else {
                player.currentAction = .fold
                player.isFolded = true
                addAction("\(player.name) folded")
            }
        } else {
            if callAmount == 0 {
                player.currentAction = .check
                addAction("\(player.name) checked")
            } else {
                player.currentAction = .fold
                player.isFolded = true
                addAction("\(player.name) folded")
            }
        }
    }

    private func handlePostFlopDecision(player: Player, handStrength: Int, callAmount: Int, potOdds: Double, shouldBluff: Bool) {
        let madeHand = handStrength >= 2
        let strongHand = handStrength >= 4
        let monsterHand = handStrength >= 6
        
        // Calculate maximum possible raise based on available chips
        let maxRaiseAmount = max(0, player.chips - currentBet)
        
        // Adjust raise amounts and aggressiveness based on difficulty
        let (baseRaise, strongHandRaise, monsterHandRaise): (Int, Int, Int)
        let aggressiveness: Double
        
        switch gameSettings.gameDifficulty {
        case .easy:
            baseRaise = 30
            strongHandRaise = 50
            monsterHandRaise = 70
            aggressiveness = 0.3
        case .medium:
            baseRaise = 50
            strongHandRaise = 80
            monsterHandRaise = 100
            aggressiveness = 0.5
        case .hard:
            baseRaise = 70
            strongHandRaise = 100
            monsterHandRaise = 150
            aggressiveness = 0.7
        }
        
        if monsterHand && player.chips > currentBet {
            let raiseAmount = min(monsterHandRaise, maxRaiseAmount)
            if raiseAmount > 0 && Double.random(in: 0...1) < aggressiveness {
                player.currentAction = .raise(raiseAmount)
                player.chips -= (currentBet + raiseAmount)
                pot += (currentBet + raiseAmount)
                currentBet += raiseAmount
                addAction("\(player.name) raised to \(currentBet)")
            } else {
                handleCall(player: player, callAmount: callAmount)
            }
        } else if strongHand && player.chips > currentBet {
            let raiseAmount = min(strongHandRaise, maxRaiseAmount)
            if raiseAmount > 0 && Double.random(in: 0...1) < aggressiveness {
                player.currentAction = .raise(raiseAmount)
                player.chips -= (currentBet + raiseAmount)
                pot += (currentBet + raiseAmount)
                currentBet += raiseAmount
                addAction("\(player.name) raised to \(currentBet)")
            } else {
                handleCall(player: player, callAmount: callAmount)
            }
        } else if madeHand || shouldBluff {
            handleCall(player: player, callAmount: callAmount)
        } else {
            if callAmount == 0 {
                // Chance to bluff based on difficulty
                if Double.random(in: 0...1) < aggressiveness && player.chips >= baseRaise {
                    let raiseAmount = min(baseRaise, maxRaiseAmount)
                    player.currentAction = .raise(raiseAmount)
                    player.chips -= (currentBet + raiseAmount)
                    pot += (currentBet + raiseAmount)
                    currentBet += raiseAmount
                    addAction("\(player.name) raised to \(currentBet)")
                } else {
                    player.currentAction = .check
                    addAction("\(player.name) checked")
                }
            } else {
                player.currentAction = .fold
                player.isFolded = true
                addAction("\(player.name) folded")
            }
        }
    }

    private func handleCall(player: Player, callAmount: Int) {
        if callAmount == 0 {
            player.currentAction = .check
            addAction("\(player.name) checked")
        } else if callAmount <= player.chips {
            player.chips -= callAmount
            pot += callAmount
            player.currentAction = .call
            addAction("\(player.name) called \(callAmount)")
        } else {
            player.currentAction = .fold
            player.isFolded = true
            addAction("\(player.name) folded")
        }
    }
    
    func performPlayerAction(_ action: Action) {
        switch action {
        case .fold:
            currentPlayer.currentAction = .fold
            addAction("\(currentPlayer.name) folded")
            
        case .check:
            currentPlayer.currentAction = .check
            addAction("\(currentPlayer.name) checked")
            
        case .call:
            currentPlayer.currentAction = .call
            let callAmount = currentBet
            currentPlayer.chips -= callAmount
            pot += callAmount
            
            addAction("\(currentPlayer.name) called \(callAmount)")
            
        case .raise(let amount):
            currentPlayer.currentAction = .raise(amount)
            
            // Calculate total amount: current bet + raise amount
            let totalAmount = currentBet + amount
            currentPlayer.chips -= totalAmount
            pot += totalAmount
            currentBet = totalAmount // Update the current bet for next players
            
            addAction("\(currentPlayer.name) raised to \(totalAmount)")
        }
        
        nextTurn()
    }
    
    func allPlayersButOneFolded() -> Bool {
        let activePlayers = players.filter { !$0.isFolded }
        return activePlayers.count == 1
    }
    
    func isCurrentPlayer(_ player: Player) -> Bool {
        return currentPlayer.id == player.id
    }
    
    func determineWinner() {
        gameStage = .showdown
        var bestHand: (Player, Int, [Card])? = nil
        
        for player in players where !player.isFolded {
            let handStrength = evaluateHand(for: player)
            let currentHandStrength = handStrength.0
            
            if let currentBestHand = bestHand {
                if currentHandStrength > currentBestHand.1 {
                    bestHand = (player, currentHandStrength, handStrength.1)
                } else if currentHandStrength == currentBestHand.1 {
                    if compareHands(cards1: handStrength.1, cards2: currentBestHand.2) {
                        bestHand = (player, currentHandStrength, handStrength.1)
                    }
                }
            } else {
                bestHand = (player, currentHandStrength, handStrength.1)
            }
        }
        
        if let winner = bestHand?.0 {
            self.winner = winner
            winningHand = bestHand?.2
            let handStrength = bestHand?.1 ?? 0
            let handDesc = handDescription(evaluation: (handStrength, winningHand ?? []))
            
            winner.chips += pot
            
            addAction("\(winner.name) wins with a \(handDesc) and receives $\(pot)", player: winner)
            isGameFinished = true

            if winner.name == "You" {
                updatePlayerChips()
            }
        }
        
        pot = 0
    }
    
    func compareHands(cards1: [Card], cards2: [Card]) -> Bool {
        let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
        let sortedCards1 = cards1.sorted { ranks.firstIndex(of: $0.rank)! > ranks.firstIndex(of: $1.rank)! }
        let sortedCards2 = cards2.sorted { ranks.firstIndex(of: $0.rank)! > ranks.firstIndex(of: $1.rank)! }
        
        for (card1, card2) in zip(sortedCards1, sortedCards2) {
            let index1 = ranks.firstIndex(of: card1.rank)!
            let index2 = ranks.firstIndex(of: card2.rank)!
            
            if index1 > index2 {
                return true
            } else if index1 < index2 {
                return false
            }
        }
        
        return false
    }
    
    func evaluateHand(for player: Player) -> (Int, [Card]) {
        return HandEvaluator.evaluateHand(for: player, communityCards: communityCards)
    }
    
    func handDescription(evaluation: (Int, [Card])) -> String {
        return HandEvaluator.handDescription(evaluation)
    }
    
    func addAction(_ description: String, player: Player? = nil) {
        let playerToUse = player ?? currentPlayer
        let cards = playerToUse.hand.map { "\($0.rank)\($0.suit)" }.joined(separator: " ")
        roundActions.append(GameAction(description: "\(description) [\(cards)]"))
    }
}
