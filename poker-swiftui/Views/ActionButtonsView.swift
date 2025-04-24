//
//  ActionButtonsView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import SwiftUI

struct ActionButtonsView: View {
    @ObservedObject var game: PokerGame
    @State private var selectedRaiseAmount: Int = 50
    @State private var showRaiseOptions = false
    @State private var showActionAmount = false
    @State private var actionAmount = 0
    @State private var actionOffset: CGFloat = 0
    private let soundManager = SoundManager.shared
    @Environment(\.colorScheme) var colorScheme
    
    private let raiseOptions = [10, 50, 100, 200, 500, 1000]
    
    private func ChipView(amount: Int, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.green.opacity(0.8) : Color.blue.opacity(0.5))
                .shadow(color: isSelected ? Color.green.opacity(0.5) : Color.blue.opacity(0.3), radius: 3)
                .frame(width: 50, height: 50)
            
            Text("$\(amount)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
        }
    }
    
    var body: some View {
        ZStack {
            if showRaiseOptions {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showRaiseOptions = false
                        }
                    }
            }
            
            VStack {
                Spacer()
                
                if showRaiseOptions {
                    // Raise options chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(raiseOptions, id: \.self) { amount in
                                Button {
                                    withAnimation(.spring()) {
                                        selectedRaiseAmount = amount
                                    }
                                } label: {
                                    ChipView(amount: amount, isSelected: amount == selectedRaiseAmount)
                                }
                                .disabled(amount > game.currentPlayer.chips)
                                .opacity(amount > game.currentPlayer.chips ? 0.5 : 1)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 40)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // Action amount indicator - Simplified animation
                if showActionAmount {
                    Text("+$\(actionAmount)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.green)
                        .offset(y: actionOffset)
                        .opacity(showActionAmount ? 1 : 0)
                        .padding(.bottom, -20)
                }
                
                HStack(spacing: 10) {
                    // Fold button remains the same
                    Button {
                        withAnimation {
                            soundManager.playFold()
                            let player = game.currentPlayer
                            player.currentAction = .fold
                            player.isFolded = true
                            game.addAction("\(player.name) folded")
                            game.nextTurn()
                        }
                    } label: {
                        Text("Fold")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: .red.opacity(0.8)))
                    .disabled(game.currentPlayer.name != "You" || game.currentPlayer.isFolded)

                    // Check button - Only show after preflop
                    if game.gameStage != .preFlop {
                        Button {
                            withAnimation {
                                let player = game.currentPlayer
                                soundManager.playCheck()
                                player.currentAction = .check
                                game.addAction("\(player.name) checked")
                                game.nextTurn()
                            }
                        } label: {
                            Text("Check")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ActionButtonStyle(backgroundColor: .blue.opacity(0.7)))
                        .disabled(
                            game.currentPlayer.name != "You" ||
                            game.currentPlayer.isFolded
                        )
                    }

                    // Call button - Don't show in preflop if first to act
                    if !(game.gameStage == .preFlop && game.currentBet == 0) {
                        Button {
                            withAnimation {
                                let player = game.currentPlayer
                                soundManager.playCall()
                                player.currentAction = .call
                                
                                // Simply use the currentBet value
                                let callAmount = min(game.currentBet, player.chips)
                                
                                showAmountAnimation(callAmount)
                                player.chips -= callAmount
                                game.pot += callAmount
                                game.addAction("\(player.name) called \(callAmount)")
                                game.nextTurn()
                            }
                        } label: {
                            Text("Call")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ActionButtonStyle(backgroundColor: .blue.opacity(0.7)))
                        .disabled(
                            game.currentPlayer.name != "You" ||
                            game.currentPlayer.isFolded ||
                            game.currentPlayer.chips <= 0
                        )
                    }

                    // Raise button remains the same
                    Button {
                        withAnimation(.spring()) {
                            if showRaiseOptions {
                                // Execute raise with selected amount
                                performRaise(amount: selectedRaiseAmount)
                                showRaiseOptions = false
                            } else {
                                // Show options when not visible
                                showRaiseOptions = true
                            }
                        }
                    } label: {
                        Text(showRaiseOptions ? "Raise $\(selectedRaiseAmount)" : "Raise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ActionButtonStyle(backgroundColor: .green.opacity(0.7)))
                    .disabled(game.currentPlayer.name != "You" || game.currentPlayer.isFolded || game.currentPlayer.chips <= 0)
                }
                .padding()
            }
        }
    }
    
    private func showAmountAnimation(_ amount: Int) {
        actionAmount = amount
        actionOffset = 20 // Start from lower position
        
        // Show and animate up
        withAnimation(.easeOut(duration: 0.3)) {
            showActionAmount = true
            actionOffset = -20 // Move to a lower final position
        }
        
        // Hide and cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showActionAmount = false
            }
            
            // Reset position after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                actionOffset = 20
            }
        }
    }
    
    private func performRaise(amount: Int) {
        soundManager.playBet()
        let player = game.currentPlayer
        let totalAmount = game.currentBet + amount
        showAmountAnimation(amount)
        player.currentAction = .raise(amount)
        player.chips -= totalAmount
        game.pot += totalAmount
        game.currentBet = totalAmount
        game.addAction("\(player.name) raised to \(totalAmount)")
        game.nextTurn()
    }
}

struct CustomButtonStyle: ButtonStyle {
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .cornerRadius(15)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    ActionButtonsView(game: .init())
}
