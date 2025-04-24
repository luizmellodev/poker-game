//
//  CardView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct CardView: View {
    let card: Card
    @Binding var revealCards: Bool
    var isHighlighted: Bool = false
    
    var body: some View {
        Group {
            if revealCards {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .overlay(
                        VStack(spacing: 2) {
                            HStack {
                                Text(card.rank)
                                    .font(.system(size: 16, weight: .bold))
                                Text(card.suit)
                                    .font(.system(size: 16))
                            }
                            .foregroundStyle(card.suit == "♥" || card.suit == "♦" ? .red : .black)
                            .padding(4)
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black.opacity(0.1), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.4, blue: 0.8),
                                Color(red: 0.2, green: 0.5, blue: 0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        GeometryReader { geometry in
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let spacing: CGFloat = 10
                                
                                for i in stride(from: 0, through: width + height, by: spacing) {
                                    path.move(to: CGPoint(x: i, y: 0))
                                    path.addLine(to: CGPoint(x: i - height, y: height))
                                }
                            }
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        }
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    )
                    .overlay(
                        Image(systemName: "suit.spade.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white.opacity(0.7), .white.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.5), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 2)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isHighlighted ? Color.yellow : Color.clear, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.1), radius: 1)
    }
    
    private func getCardColor(suit: String) -> Color {
        switch suit {
        case "♥", "♦":
            return .red
        case "♠", "♣":
            return .black
        default:
            return .black
        }
    }
}
