//
//  HandsEvaluator.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI
import Combine

class HandEvaluator {
    static let ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
    static let suits = ["♠", "♥", "♦", "♣"]
    
    static func evaluateHand(for player: Player, communityCards: [Card]) -> (Int, [Card]) {
        if communityCards.isEmpty {
            // Only evaluate player's hand during preflop
            if player.hand[0].rank == player.hand[1].rank {
                return (200, player.hand) // One Pair
            }
            return (100, [sortCards(player.hand)[0]]) // High Card
        }
        
        let allCards = player.hand + communityCards
        let sortedHand = sortCards(allCards)
        
        // Array to store all possible combinations
        var combinations: [(Int, [Card])] = []
        
        // Only check combinations that require 5+ cards if we have enough cards
        if allCards.count >= 5 {
            // Check all possible combinations with current cards
            if let royalFlush = royalFlushCards(cards: sortedHand) {
                combinations.append((1000, royalFlush))
            }
            if let straightFlush = straightFlushCards(cards: sortedHand) {
                combinations.append((900, straightFlush))
            }
            if let fourKind = fourOfAKindCards(cards: sortedHand) {
                combinations.append((800, fourKind))
            }
            if let fullHouse = fullHouseCards(cards: sortedHand) {
                combinations.append((700, fullHouse))
            }
            if let flush = flushCards(cards: sortedHand) {
                combinations.append((600, flush))
            }
            if let straight = straightCards(cards: sortedHand) {
                combinations.append((500, straight))
            }
        }
        
        // These combinations don't require 5 cards
        if let threeKind = threeOfAKindCards(cards: sortedHand) {
            combinations.append((400, threeKind))
        }
        if let twoPair = twoPairCards(cards: sortedHand) {
            combinations.append((300, twoPair))
        }
        if let onePair = onePairCards(cards: allCards) {
            combinations.append((200, onePair))
        }
        
        // Sort combinations by value (highest first)
        combinations.sort { $0.0 > $1.0 }
        
        // Return the best combination
        if let bestCombo = combinations.first {
            return bestCombo
        }
        
        // If no combination found, return high card
        let highCard = sortCards(allCards)[0]
        return (100, [highCard])
    }

    private static func royalFlushCards(cards: [Card]) -> [Card]? {
        for suit in suits {
            let sameSuitCards = cards.filter { $0.suit == suit }
            if let straight = straightCards(cards: sameSuitCards) {
                if straight[0].rank == "A" && straight[1].rank == "K" {
                    return straight
                }
            }
        }
        return nil
    }

    private static func straightFlushCards(cards: [Card]) -> [Card]? {
        for suit in suits {
            let sameSuitCards = cards.filter { $0.suit == suit }
            if let straight = straightCards(cards: sameSuitCards) {
                return straight
            }
        }
        return nil
    }

    private static func fourOfAKindCards(cards: [Card]) -> [Card]? {
        for rank in ranks {
            let sameRankCards = cards.filter { $0.rank == rank }
            if sameRankCards.count >= 4 {
                let kicker = cards.first { $0.rank != rank }
                return sameRankCards.prefix(4) + [kicker!]
            }
        }
        return nil
    }

    private static func fullHouseCards(cards: [Card]) -> [Card]? {
        var result = [Card]()
        var remainingCards = cards
        
        if let threeOfKind = threeOfAKindCards(cards: cards) {
            result += threeOfKind
            remainingCards = remainingCards.filter { !threeOfKind.contains($0) }
            
            if let pair = onePairCards(cards: remainingCards) {
                result += pair
                return result
            }
        }
        return nil
    }

    private static func flushCards(cards: [Card]) -> [Card]? {
        for suit in suits {
            let sameSuitCards = cards.filter { $0.suit == suit }
            if sameSuitCards.count >= 5 {
                return Array(sameSuitCards.prefix(5))
            }
        }
        return nil
    }

    private static func straightCards(cards: [Card]) -> [Card]? {
        // Return nil if we don't have enough cards for a straight
        guard cards.count >= 5 else { return nil }
        
        var uniqueRankCards = [Card]()
        for rank in ranks {
            if let card = cards.first(where: { $0.rank == rank }) {
                uniqueRankCards.append(card)
            }
        }
        
        // Return nil if we don't have enough unique ranks for a straight
        guard uniqueRankCards.count >= 5 else { return nil }
        
        // Now we can safely evaluate straights
        for i in 0...(uniqueRankCards.count - 5) {
            let possibleStraight = Array(uniqueRankCards[i...(i + 4)])
            if isStraight(possibleStraight) {
                return possibleStraight
            }
        }
        
        // Check for wheel straight (A-2-3-4-5)
        if let aceCard = cards.first(where: { $0.rank == "A" }) {
            let lowCards = cards.filter { ["2", "3", "4", "5"].contains($0.rank) }
            if lowCards.count >= 4 {
                var wheelStraight = lowCards.prefix(4).map { $0 }
                wheelStraight.append(aceCard)
                if isStraight(wheelStraight) {
                    return wheelStraight
                }
            }
        }
        
        return nil
    }

    private static func isStraight(_ cards: [Card]) -> Bool {
        guard cards.count == 5 else { return false }
        
        if cards[0].rank == "A" && cards[1].rank == "5" {
            let expectedRanks = ["A", "5", "4", "3", "2"]
            return cards.map({ $0.rank }) == expectedRanks
        }
        
        for i in 0...(cards.count - 2) {
            let currentRankIndex = rankValue(cards[i].rank)
            let nextRankIndex = rankValue(cards[i + 1].rank)
            if currentRankIndex != nextRankIndex + 1 {
                return false
            }
        }
        return true
    }

    private static func threeOfAKindCards(cards: [Card]) -> [Card]? {
        for rank in ranks {
            let sameRankCards = cards.filter { $0.rank == rank }
            if sameRankCards.count >= 3 {
                let kickers = cards.filter { $0.rank != rank }
                    .prefix(2)
                return sameRankCards.prefix(3) + Array(kickers)
            }
        }
        return nil
    }

    private static func twoPairCards(cards: [Card]) -> [Card]? {
        var result = [Card]()
        var remainingCards = cards
        
        if let firstPair = onePairCards(cards: cards) {
            result += firstPair
            remainingCards = remainingCards.filter { !firstPair.contains($0) }
            
            if let secondPair = onePairCards(cards: remainingCards) {
                result += secondPair
                remainingCards = remainingCards.filter { !secondPair.contains($0) }
                
                if let kicker = remainingCards.first {
                    result.append(kicker)
                }
                
                return result
            }
        }
        return nil
    }

    private static func onePairCards(cards: [Card]) -> [Card]? {
        for rank in ranks.reversed() {
            let sameRankCards = cards.filter { $0.rank == rank }
            if sameRankCards.count >= 2 {
                // Return exactly the pair without kickers
                return Array(sameRankCards.prefix(2))
            }
        }
        return nil
    }

    public static func sortCards(_ cards: [Card]) -> [Card] {
        return cards.sorted { card1, card2 in
            let rank1Value = rankValue(card1.rank)
            let rank2Value = rankValue(card2.rank)
            return rank1Value > rank2Value
        }
    }

    private static func rankValue(_ rank: String) -> Int {
        return ranks.firstIndex(of: rank) ?? 0
    }

    static func handDescription(_ evaluation: (Int, [Card])) -> String {
        switch evaluation.0 {
        case 1000: return "Royal Flush"
        case 900: return "Straight Flush"
        case 800: return "Four of a Kind"
        case 700: return "Full House"
        case 600: return "Flush"
        case 500: return "Straight"
        case 400: return "Three of a Kind"
        case 300: return "Two Pair"
        case 200: return "One Pair"
        default: return "High Card"
        }
    }
}
