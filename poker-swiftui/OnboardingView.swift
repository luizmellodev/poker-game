import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameSettings = GameSettings.shared
    @State private var showTutorial = false
    @State private var slideOffset: CGFloat = 1000
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Welcome to Fast Hand Poker!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 50)
                    .offset(x: slideOffset)
                
                VStack(spacing: 20) {
                    infoCard(
                        title: "Traditional Rules",
                        description: "Play Texas Hold'em poker with traditional rules and betting rounds.",
                        iconName: "cards.playing")
                    
                    infoCard(
                        title: gameSettings.gameDifficulty == .hard ? "Premium Mode" : "Free to Play",
                        description: gameSettings.gameDifficulty == .hard ? "Purchase chips to keep playing" : "Watch ads to get free chips",
                        iconName: gameSettings.gameDifficulty == .hard ? "dollarsign.circle" : "play.circle")
                }
                .offset(x: -slideOffset)
                
                Spacer()
                
                Text("Do you know how to play poker?")
                    .font(.title3)
                    .foregroundColor(.white)
                    .opacity(opacity)
                
                HStack(spacing: 20) {
                    actionButton("Yes, Let's Play!") {
                        dismiss()
                    }
                    
                    actionButton("No, Show Tutorial") {
                        showTutorial = true
                    }
                }
                .opacity(opacity)
                .padding(.bottom, 50)
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(duration: 0.8, bounce: 0.4).delay(0.3)) {
                slideOffset = 0
            }
            withAnimation(.easeIn.delay(1.2)) {
                opacity = 1
            }
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView()
        }
    }
    
    private func infoCard(title: String, description: String, iconName: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.blue)
                .frame(width: 60, height: 60)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(15)
    }
    
    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 160, height: 50)
                .background(Color.blue.opacity(0.3))
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.blue.opacity(0.5), lineWidth: 1))
                .cornerRadius(15)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
