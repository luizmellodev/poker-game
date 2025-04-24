import SwiftUI

struct HandHighlight {
    let description: String
    let value: Int
    let highlightedCards: [Card]
    let isVisible: Bool
}

class HandHighlightManager {
    static func getCurrentHandHighlight(player: Player, game: PokerGame) -> HandHighlight {
        // Don't show anything in hard mode
        if GameSettings.shared.gameDifficulty == .hard {
            return HandHighlight(description: "", value: 0, highlightedCards: [], isVisible: false)
        }
        
        // During preflop, only show pocket pairs
        if game.communityCards.isEmpty {
            if player.hand[0].rank == player.hand[1].rank {
                return HandHighlight(
                    description: "One Pair",
                    value: 200,
                    highlightedCards: player.hand,
                    isVisible: true
                )
            }
            return HandHighlight(
                description: "",
                value: 0,
                highlightedCards: [],
                isVisible: false
            )
        }
        
        // After preflop
        let evaluation = HandEvaluator.evaluateHand(for: player, communityCards: game.communityCards)
        
        // Only show highlight if there's an actual combination
        let hasValidCombination = evaluation.0 >= 200 // 200 is One Pair
        return HandHighlight(
            description: HandEvaluator.handDescription(evaluation),
            value: evaluation.0,
            highlightedCards: evaluation.1,
            isVisible: hasValidCombination
        )
    }
    
    static func shouldHighlightCard(_ card: Card, in highlight: HandHighlight) -> Bool {
        highlight.highlightedCards.contains { $0.rank == card.rank && $0.suit == card.suit }
    }
}
