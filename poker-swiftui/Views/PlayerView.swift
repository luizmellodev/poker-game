//
//  PlayerView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import SwiftUI

struct PlayerView: View {
    let player: Player
    let isCurrentPlayer: Bool
    @ObservedObject var game: PokerGame
    let totalPlayers: Int
    @Binding var revealCards: Bool
    @State private var showAction: Bool = false
    
    var body: some View {
        PlayerContainer(isCurrentPlayer: isCurrentPlayer) {
            VStack(spacing: 4) {
                PlayerInfoView(
                    player: player,
                    game: game,
                    isThinking: game.thinkingPlayerIndex != nil &&
                              game.players[game.thinkingPlayerIndex!].id == player.id
                )
                
                PlayerCardsView(
                    player: player,
                    game: game,
                    cardSize: cardSize,
                    revealCards: $revealCards
                )
                
                if let action = player.currentAction {
                    PlayerActionView(
                        action: action,
                        showAction: showAction
                    )
                    .onAppear {
                        withAnimation(.spring(dampingFraction: 0.7)) {
                            showAction = true
                        }
                    }
                    .onDisappear {
                        showAction = false
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .overlay(alignment: .topTrailing) {
            if player.isFolded {
                FoldedBadge()
            }
        }
        .opacity(player.isFolded ? game.isGameFinished ? 1.0 : 0.7 : 1.0)
        .frame(maxWidth: playerFrameWidth)
    }
    
    private var cardSize: CGSize {
        // Adjust card sizes to maintain proportion
        let baseWidth: CGFloat = totalPlayers > 4 ? 40 : 55
        let baseHeight: CGFloat = totalPlayers > 4 ? 56 : 77 // Maintaining 1.4 aspect ratio
        return CGSize(width: baseWidth, height: baseHeight)
    }
    
    private var playerFrameWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = 10
        let numberOfPlayers = CGFloat(totalPlayers - 1) // -1 porque não incluímos o jogador humano
        return (screenWidth - (spacing * (numberOfPlayers + 1))) / numberOfPlayers
    }
}

// MARK: - Subviews

private struct PlayerContainer<Content: View>: View {
    let isCurrentPlayer: Bool
    let content: Content
    
    init(isCurrentPlayer: Bool, @ViewBuilder content: () -> Content) {
        self.isCurrentPlayer = isCurrentPlayer
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isCurrentPlayer ? Color.green.opacity(1) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
    }
}

private struct PlayerInfoView: View {
    let player: Player
    let game: PokerGame
    let isThinking: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            if isThinking {
                Text("🤔")
                    .font(.system(size: 12))
                    .transition(.scale.combined(with: .opacity))
            }
            
            Text(player.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
            
            Text("$\(player.chips)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.yellow)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .cornerRadius(8)
    }
}

private struct PlayerCardsView: View {
    let player: Player
    let game: PokerGame
    let cardSize: CGSize
    @Binding private var revealCards: Bool
    
    init(player: Player, game: PokerGame, cardSize: CGSize, revealCards: Binding<Bool>) {
        self.player = player
        self.game = game
        self.cardSize = cardSize
        self._revealCards = revealCards
    }
    
    var body: some View {
        HStack(spacing: game.isGameFinished ? 2 :  -cardSize.width * 0.3) {
            ForEach(player.hand) { card in
                CardView(
                    card: card,
                    revealCards: $revealCards
                )
                .frame(width: cardSize.width, height: cardSize.height)
                .opacity(cardOpacity)
                .rotation3DEffect(
                    .degrees(revealCards ? 0 : 180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
            }
        }
        .padding(.vertical, 4)
        .onChange(of: game.isGameFinished) { _, finished in
            if finished {
                withAnimation(.easeInOut(duration: 0.5)) {
                    revealCards = true
                }
            }
        }
    }

    private var cardOpacity: Double {
        if game.isGameFinished {
            return 1.0
        }
        return player.isFolded ? 0.4 : 1.0
    }
}

private struct PlayerActionView: View {
    let action: Action
    let showAction: Bool
    
    var body: some View {
        Text(action.description)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(actionColor(for: action).opacity(0.3))
            .clipShape(Capsule())
            .opacity(showAction ? 1 : 0)
            .offset(y: showAction ? 0 : 10)
    }
    
    private func actionColor(for action: Action) -> Color {
        switch action {
        case .raise:
            return .red
        case .call:
            return .blue
        case .check:
            return .green
        case .fold:
            return .gray
        }
    }
}

private struct FoldedBadge: View {
    var body: some View {
        Text("FOLDED")
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.red.opacity(0.8))
            .clipShape(Capsule())
            .offset(x: -8, y: -10)
    }
}
