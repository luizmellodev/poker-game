//
//  CommunityCardsView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import SwiftUI

struct CommunityCardsView: View {
    @ObservedObject var game: PokerGame
    @State private var flippedCards: Set<Int> = []
    @State private var cardOffsets: [CGFloat] = [0, 0, 0, 0, 0]
    
    private var handHighlight: HandHighlight {
        if let player = game.players.first(where: { $0.name == "You" }) {
            return HandHighlightManager.getCurrentHandHighlight(player: player, game: game)
        }
        return HandHighlight(description: "", value: 0, highlightedCards: [], isVisible: false)
    }
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(zip(game.communityCards.indices, game.communityCards)), id: \.0) { index, card in
                CardView(
                    card: card,
                    revealCards: .constant(true),
                    isHighlighted: HandHighlightManager.shouldHighlightCard(card, in: handHighlight)
                )
                .frame(width: 60, height: 84)
                .rotation3DEffect(
                    .degrees(flippedCards.contains(index) ? 0 : 180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .offset(y: cardOffsets[index])
                .opacity(flippedCards.contains(index) ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: flippedCards)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            cardOffsets[index] = 0
                            flippedCards.insert(index)
                        }
                        SoundManager.shared.playCardFlip()
                    }
                }
            }
            
            ForEach(game.communityCards.count..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 60, height: 84)
            }
        }
        .padding(.horizontal)
        .onAppear {
            cardOffsets = Array(repeating: -200, count: 5)
        }
    }
}

#Preview {
    CommunityCardsView(game: .init())
}
