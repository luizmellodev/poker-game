//
//  MenuView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var gameSettings = GameSettings.shared
    @State private var showSettings = false
    @State private var showGameView = false
    @State private var showAdView = false
    @State private var showChipsStore = false
    
    // Added animation state variables
    @State private var titleOffset: CGFloat = -400
    @State private var buttonsOffset: CGFloat = 400
    @State private var showChips: Bool = false
    @State private var lowChipsAnimation = false
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showOnboarding = false
    @State private var showTutorial = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.05, green: 0.05, blue: 0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Dynamic background pattern
                ZStack {
                    ForEach(0..<10) { index in
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 20, height: 20)
                            .offset(x: CGFloat.random(in: -200...200),
                                    y: CGFloat.random(in: -400...400))
                            .animation(
                                Animation.easeInOut(duration: 4)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: showChips
                            )
                    }
                }
                
                VStack(spacing: 40) {
                    // Title section
                    Text("Fast Hand")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: titleOffset)
                        .overlay(
                            Text("Fast Hand")
                                .font(.system(size: 44, weight: .bold))
                                .foregroundColor(.blue.opacity(0.5))
                                .offset(x: titleOffset + 2, y: 2)
                        )
                    
                    // Menu buttons
                    VStack(spacing: 25) {
                        menuButton("Play Now") {
                            withAnimation(.spring()) {
                                if gameSettings.playerChips < 50 {
                                    // Show warning message if chips are low
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        lowChipsAnimation.toggle()
                                    }
                                } else {
                                    showGameView = true
                                }
                            }
                        }
                        
                        menuButton("Settings") {
                            withAnimation(.spring()) {
                                showSettings = true
                            }
                        }
                        
                        menuButton("How to Play") {
                            withAnimation(.spring()) {
                                showTutorial = true
                            }
                        }
                        
                        // Modified Add Chips button
                        Button {
                            if gameSettings.dailyClaimsRemaining == 0 {
                                if gameSettings.gameDifficulty == .hard {
                                    showChipsStore = true
                                } else {
                                    showAdView = true
                                }
                            }
                        } label: {
                            Text(gameSettings.gameDifficulty == .hard ? "Buy Chips" : "Get Free Chips")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: gameSettings.playerChips < 50 ? 240 : 220, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.blue.opacity(gameSettings.playerChips < 50 ? 0.5 : 0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.blue.opacity(0.5), lineWidth: gameSettings.playerChips < 50 ? 2 : 1)
                                        )
                                )
                                .shadow(color: .blue.opacity(gameSettings.playerChips < 50 ? 0.5 : 0.3), radius: 10, x: 0, y: 5)
                                .scaleEffect(lowChipsAnimation ? 1.1 : 1.0)
                                .overlay(
                                    VStack {
                                        if gameSettings.playerChips < 50 {
                                            Text(gameSettings.gameDifficulty == .hard ? "Purchase Required!" : "Watch Ad for Chips!")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                                .padding(5)
                                                .background(Color.black.opacity(0.7))
                                                .cornerRadius(5)
                                                .offset(y: -35)
                                        }
                                    }
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Add Daily Claim button
                        if gameSettings.dailyClaimsRemaining > 0 {
                            Button {
                                withAnimation(.spring()) {
                                    if gameSettings.claimDailyChips() {
                                        // Show success message or animation
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                            showChips = true
                                        }
                                    }
                                }
                            } label: {
                                Text("Claim Free 500 Chips (\(gameSettings.dailyClaimsRemaining) left)")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 280, height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.green.opacity(0.3))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
                                            )
                                    )
                                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .offset(x: buttonsOffset)
                    
                    // Player info
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            
                            Text("\(gameSettings.playerChips)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .opacity(showChips ? 1 : 0)
                        .scaleEffect(showChips ? 1 : 0.5)
                        
                        Text(gameSettings.gameDifficulty.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                            .opacity(showChips ? 1 : 0)
                    }
                }
            }
            .onAppear {
                // Animate elements on appear
                withAnimation(.spring(dampingFraction: 0.7).delay(0.3)) {
                    titleOffset = 0
                }
                withAnimation(.spring(dampingFraction: 0.7).delay(0.5)) {
                    buttonsOffset = 0
                }
                withAnimation(.spring().delay(0.7)) {
                    showChips = true
                }
                
                // Add this for low chips animation
                if gameSettings.playerChips < 50 {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
                        lowChipsAnimation = true
                    }
                }
                
                // Start background music
                SoundManager.shared.playBackgroundMusic()
                
                if !hasSeenOnboarding {
                    showOnboarding = true
                    hasSeenOnboarding = true
                }
            }
            .onDisappear {
                SoundManager.shared.stopBackgroundMusic()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showGameView) {
                ContentView()
            }
            .sheet(isPresented: $showChipsStore) {
                ChipsStoreView(onComplete: {
                    gameSettings.addChips(amount: 1000)
                })
            }
            .sheet(isPresented: $showAdView) {
                AdView(onComplete: {
                    gameSettings.addChips(amount: 1000)
                })
            }
            .sheet(isPresented: $showOnboarding) {
                OnboardingView()
            }
            .sheet(isPresented: $showTutorial) {
                TutorialView()
            }
        }
    }
    
    private func menuButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            SoundManager.shared.playMenuSound()
            action()
        }) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 220, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                        )
                )
                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(dampingFraction: 0.5), value: configuration.isPressed)
    }
}
