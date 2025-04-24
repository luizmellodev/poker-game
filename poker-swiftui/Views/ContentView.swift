import SwiftUI
import EffectsLibrary

struct ContentView: View {
    
    @StateObject var game = PokerGame()
    @State private var showingHistory = false
    @State private var showingVictoryMessage = false
    @State private var showingAdView = false
    @State private var isSoundMuted = false
    @State private var isViewDismissing = false
    @State private var revealCards = false
    @State private var showingHandGuide = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let gradientColors = [
        Color(red: 0.1, green: 0.2, blue: 0.3),
        Color(red: 0.05, green: 0.1, blue: 0.15)
    ]
    
    var configFireworks = FireworksConfig(
        backgroundColor: .clear,
        intensity: .high,
        lifetime: .medium,
        initialVelocity: .fast
    )
    
    private let soundManager = SoundManager.shared
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 8) {
                HStack {
                    Button(action: {
                        isViewDismissing = true
                        game.isGameFinished = true
                        game.updatePlayerChips()
                        soundManager.stopBackgroundMusic()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        isSoundMuted.toggle()
                        SoundManager.shared.toggleSound()
                    } label: {
                        Image(systemName: isSoundMuted ? "speaker.slash.fill" : "speaker.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(game.players.first(where: { $0.name == "You" })?.chips ?? 0)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .padding(8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    .padding(.trailing, 8)
                }
                .padding(.top)
                
                playerListView()
                    .padding(.horizontal, 8)
                    .padding(.top, 10)
                
                HStack(spacing: 12) {
                    potView("Current Pot", value: game.pot)
                    potView("To Call", value: game.currentBet)
                }
                .padding(.vertical, 4)
                .padding(.top, 10)
                
                CommunityCardsView(game: game)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .padding(.top, 10)
                
                Spacer()
                
                if let currentPlayer = game.players.first(where: { $0.name == "You" }) {
                    PlayerHandDisplay(player: currentPlayer, game: game)
                        .frame(height: 80)
                        .zIndex(1)
                        .padding(.top, 8)
                    
                    if let action = currentPlayer.currentAction {
                        Text(action.description)
                            .foregroundColor(.white)
                            .padding(6)
                            .cornerRadius(10)
                    }
                }
                
                if !game.isGameFinished {
                    ActionButtonsView(game: game)
                        .padding(.bottom, 8)
                        .zIndex(2)
                } else {
                    HStack(spacing: 20) {
                        gameButton("Start New Game", color: .blue) {
                            game.resetGame()
                            self.revealCards = false
                        }
                        
                        gameButton("Show History", color: .green) {
                            showingHistory = true
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding(.top)
            .blur(radius: showingVictoryMessage ? 5 : 0)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            
            if showingVictoryMessage {
                withAnimation(.spring()) {
                    VictoryMessageView(winnerName: game.winner?.name ?? "Unknown")
                        .transition(.scale)
                }

                if game.winner?.name == "You" {
                    FireworksView(config: configFireworks)
                        .ignoresSafeArea()
                }
            }
            if GameSettings.shared.gameDifficulty != .hard {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            showingHandGuide = true
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .frame(width: 20, height: 20)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(8  )
                                .background(Color.blue.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 10)
                        .padding(.bottom, 200)
                    }
                }
                .blur(radius: showingVictoryMessage ? 5 : 0)
            }
            if game.showingLowChipsAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Low on Chips!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("You need more chips to continue playing.")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        if GameSettings.shared.gameDifficulty == .hard {
                            showingAdView = true
                        } else {
                            GameSettings.shared.addChips(amount: 1000)
                            game.resetGame()
                        }
                        game.showingLowChipsAlert = false
                    } label: {
                        Text(GameSettings.shared.gameDifficulty == .hard ? "Watch Ad for Chips" : "Get 1000 Chips")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        game.showingLowChipsAlert = false
                    } label: {
                        Text("Return to Menu")
                        .foregroundColor(.gray)
                    }
                }
                .padding(30)
                .background(Color.black.opacity(0.9))
                .cornerRadius(20)
                .shadow(radius: 20)
                .padding(40)
                .transition(.scale)
            }
        }
        .sheet(isPresented: $showingHistory) {
            GameHistoryView(actions: game.roundActions)
        }
        .sheet(isPresented: $showingHandGuide) {
            PokerHandGuideView()
        }
        .onDisappear {
            game.updatePlayerChips()
            if isViewDismissing {
                game.updatePlayerChips()
                game.isGameFinished = true
                soundManager.stopBackgroundMusic()
            }
        }
        .onChange(of: game.isGameFinished) { _, finished in
            if finished {
                showVictoryMessage()
                self.revealCards = true
                
            }
        }
    }
    
    private func showVictoryMessage() {
        showingVictoryMessage = true
        if game.winner?.name == "You" {
            soundManager.playWin()
        } else {
            soundManager.playLose()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            showingVictoryMessage = false
        }
    }
    
    private func potView(_ title: String, value: Int) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white)
            Text("$\(value)")
                .font(.title3)
                .bold()
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .cornerRadius(15)
    }
    
    private func gameButton(_ title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            if title == "Start New Game" {
                soundManager.playGameStart()
            }
            action()
        }) {
            Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color.opacity(0.8))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
    
    @ViewBuilder
    private func playerListView() -> some View {
        let bots = game.players.filter { $0.name != "You" }
        
        if bots.count <= 3 {
            HStack {
                ForEach(bots) { player in
                    PlayerView(
                        player: player,
                        isCurrentPlayer: game.isCurrentPlayer(player),
                        game: game,
                        totalPlayers: game.players.count,
                        revealCards: $revealCards
                    )
                }
            }
        } else {
            VStack(spacing: 10) {
                HStack {
                    ForEach(Array(bots.prefix(3))) { player in
                        PlayerView(
                            player: player,
                            isCurrentPlayer: game.isCurrentPlayer(player),
                            game: game,
                            totalPlayers: game.players.count,
                            revealCards: $revealCards
                        )
                    }
                }
                if bots.count > 3 {
                    HStack {
                        ForEach(Array(bots.dropFirst(3))) { player in
                            PlayerView(
                                player: player,
                                isCurrentPlayer: game.isCurrentPlayer(player),
                                game: game,
                                totalPlayers: game.players.count,
                                revealCards: $revealCards
                            )
                        }
                    }
                }
            }
        }
    }
}
