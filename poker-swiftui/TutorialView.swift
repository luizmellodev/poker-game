import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentPage = 0
    @State private var slideOffset: CGFloat = 1000
    @State private var showHandGuide = false
    
    let tutorials = [
        TutorialPage(title: "Game Overview",
                     description: "In poker, strategy is key! You'll receive two private cards and share five community cards with other players. Your goal is to make the best hand combination or convince others you have it! Use strategic betting to win, whether you have good cards or are bluffing.",
                     icon: "brain.head.profile"),
        TutorialPage(title: "Betting Strategy",
                     description: "• Check if you want to pass without betting\n• Bet or Raise when you have good cards or want to bluff\n• Call if you think your opponent might be bluffing\n• Fold to save your chips if you think you're beaten\n\nRemember: Poker is about playing your opponents, not just your cards!",
                     icon: "chart.line.uptrend.xyaxis"),
        TutorialPage(title: "Hand Rankings",
                     description: "Learn all possible poker hands and their rankings.",
                     icon: "star.fill",
                     hasShowCardsButton: true),
        TutorialPage(title: "Game Flow",
                     description: "1. Get your two cards\n2. First betting round\n3. See three community cards (Flop)\n4. Second betting round\n5. Fourth card (Turn) & bet\n6. Final card (River) & last bet\n7. Show cards and win!",
                     icon: "arrow.triangle.turn.up.right.diamond.fill")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            VStack {
                HStack {
                    ForEach(0..<tutorials.count) { index in
                        Rectangle()
                            .fill(currentPage >= index ? Color.blue : Color.gray)
                            .frame(height: 4)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding()
                
                TabView(selection: $currentPage) {
                    ForEach(0..<tutorials.count, id: \.self) { index in
                        tutorialPage(tutorials[index])
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                Button(currentPage == tutorials.count - 1 ? "Start Playing!" : "Next") {
                    if currentPage == tutorials.count - 1 {
                        dismiss()
                    } else {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(25)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showHandGuide) {
            PokerHandGuideView()
        }
    }
    
    private func tutorialPage(_ page: TutorialPage) -> some View {
        VStack(spacing: 30) {
            Image(systemName: page.icon)
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .frame(width: 120, height: 120)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())
                .offset(x: slideOffset)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if page.hasShowCardsButton ?? false {
                Button {
                    showHandGuide = true
                } label: {
                    HStack {
                        Image(systemName: "eye.fill")
                        Text("Show Poker Hands")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(20)
                }
            }
        }
        .onAppear {
            withAnimation(.spring()) {
                slideOffset = 0
            }
        }
    }
}

struct TutorialPage {
    let title: String
    let description: String
    let icon: String
    var hasShowCardsButton: Bool?
}
