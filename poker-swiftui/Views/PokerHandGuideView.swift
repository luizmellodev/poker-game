import SwiftUI

struct PokerHandGuideView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedHand: PokerHand?
    @State private var showCards = false
    
    enum PokerHand: String, CaseIterable {
        case royalFlush = "Royal Flush"
        case straightFlush = "Straight Flush"
        case fourOfAKind = "Four of a Kind"
        case fullHouse = "Full House"
        case flush = "Flush"
        case straight = "Straight"
        case threeOfAKind = "Three of a Kind"
        case twoPair = "Two Pair"
        case onePair = "One Pair"
        
        var importance: Int {
            switch self {
            case .royalFlush: return 1
            case .straightFlush: return 2
            case .fourOfAKind: return 3
            case .fullHouse: return 4
            case .flush: return 5
            case .straight: return 6
            case .threeOfAKind: return 7
            case .twoPair: return 8
            case .onePair: return 9
            }
        }
        
        var handDescription: String {
            switch self {
            case .royalFlush: return "The best possible hand: A-K-Q-J-10 all in the same suit"
            case .straightFlush: return "Five consecutive cards all in the same suit"
            case .fourOfAKind: return "Four cards of the same rank"
            case .fullHouse: return "Three of a kind plus a pair"
            case .flush: return "Any five cards of the same suit"
            case .straight: return "Five consecutive cards of different suits"
            case .threeOfAKind: return "Three cards of the same rank"
            case .twoPair: return "Two different pairs"
            case .onePair: return "Two cards of the same rank"
            }
        }
        
        var exampleCards: [Card] {
            switch self {
            case .royalFlush:
                return [Card(rank: "A", suit: "♠"), Card(rank: "K", suit: "♠"), Card(rank: "Q", suit: "♠"),
                        Card(rank: "J", suit: "♠"), Card(rank: "10", suit: "♠")]
            case .straightFlush:
                return [Card(rank: "9", suit: "♥"), Card(rank: "8", suit: "♥"), Card(rank: "7", suit: "♥"),
                        Card(rank: "6", suit: "♥"), Card(rank: "5", suit: "♥")]
            case .fourOfAKind:
                return [Card(rank: "K", suit: "♠"), Card(rank: "K", suit: "♥"), Card(rank: "K", suit: "♦"),
                        Card(rank: "K", suit: "♣"), Card(rank: "A", suit: "♠")]
            case .fullHouse:
                return [Card(rank: "Q", suit: "♠"), Card(rank: "Q", suit: "♥"), Card(rank: "Q", suit: "♦"),
                        Card(rank: "J", suit: "♠"), Card(rank: "J", suit: "♥")]
            case .flush:
                return [Card(rank: "A", suit: "♦"), Card(rank: "J", suit: "♦"), Card(rank: "8", suit: "♦"),
                        Card(rank: "6", suit: "♦"), Card(rank: "3", suit: "♦")]
            case .straight:
                return [Card(rank: "8", suit: "♠"), Card(rank: "7", suit: "♥"), Card(rank: "6", suit: "♦"),
                        Card(rank: "5", suit: "♣"), Card(rank: "4", suit: "♠")]
            case .threeOfAKind:
                return [Card(rank: "10", suit: "♠"), Card(rank: "10", suit: "♥"), Card(rank: "10", suit: "♦"),
                        Card(rank: "K", suit: "♠"), Card(rank: "7", suit: "♥")]
            case .twoPair:
                return [Card(rank: "J", suit: "♠"), Card(rank: "J", suit: "♥"), Card(rank: "9", suit: "♦"),
                        Card(rank: "9", suit: "♣"), Card(rank: "A", suit: "♠")]
            case .onePair:
                return [Card(rank: "8", suit: "♠"), Card(rank: "8", suit: "♥"), Card(rank: "K", suit: "♦"),
                        Card(rank: "7", suit: "♣"), Card(rank: "2", suit: "♠")]
            }
        }
        
        var highlightedIndexes: [Int] {
            switch self {
            case .royalFlush: return [0, 1, 2, 3, 4] // All cards are important
            case .straightFlush: return [0, 1, 2, 3, 4] // All cards are important
            case .fourOfAKind: return [0, 1, 2, 3] // Only the four matching cards
            case .fullHouse: return [0, 1, 2, 3, 4] // All cards form the combination
            case .flush: return [0, 1, 2, 3, 4] // All cards of same suit
            case .straight: return [0, 1, 2, 3, 4] // All consecutive cards
            case .threeOfAKind: return [0, 1, 2] // Only the three matching cards
            case .twoPair: return [0, 1, 2, 3] // Only the two pairs
            case .onePair: return [0, 1] // Only the pair
            }
        }
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Poker Hand Guide")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                if selectedHand == nil {
                    Text("Tap a hand to learn more")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(PokerHand.allCases.sorted(by: { $0.importance < $1.importance }), id: \.self) { hand in
                            Button {
                                withAnimation {
                                    selectedHand = hand
                                    showCards = true
                                }
                            } label: {
                                VStack {
                                    Text(hand.rawValue)
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                        .frame(height: 50)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedHand == hand ? Color.blue : Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding()
                    
                    if let selectedHand = selectedHand, showCards {
                        VStack(spacing: 15) {
                            Text(selectedHand.handDescription)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 5) {
                                ForEach(Array(zip(selectedHand.exampleCards.indices, selectedHand.exampleCards)), id: \.0) { index, card in
                                    CardView(
                                        card: card,
                                        revealCards: .constant(true),
                                        isHighlighted: selectedHand.highlightedIndexes.contains(index)
                                    )
                                    .frame(width: 60, height: 84)
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.top)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
                
                Button("Close") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue.opacity(0.3))
                .cornerRadius(25)
                .padding(.bottom)
            }
        }
    }
}
