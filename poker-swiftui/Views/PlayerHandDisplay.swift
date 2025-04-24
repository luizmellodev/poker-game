//
//  PlayerHandDisplay.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct PlayerHandDisplay: View {
    let player: Player
    let game: PokerGame
    @State private var isDealt = false
    @State private var cardOffsets: [CGFloat] = [-300, 300]
    @State private var cardRotations: [Double] = [-30, 30]
    
    private var handHighlight: HandHighlight {
        HandHighlightManager.getCurrentHandHighlight(player: player, game: game)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                ForEach(Array(zip(player.hand.indices, player.hand)), id: \.0) { index, card in
                    CardView(
                        card: card,
                        revealCards: .constant(true),
                        isHighlighted: HandHighlightManager.shouldHighlightCard(card, in: handHighlight)
                    )
                    .frame(width: 60, height: 80)
                    .offset(x: isDealt ? 0 : cardOffsets[index])
                    .rotationEffect(.degrees(isDealt ? 0 : cardRotations[index]))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isDealt)
                }
            }
            
            Text(handHighlight.description)
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .bold))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(8)
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding(.top, 20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isDealt = true
                }
                for i in 0..<2 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                        SoundManager.shared.playCardFlip()
                    }
                }
            }
        }
    }
}
