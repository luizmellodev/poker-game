//
//  GameHistoryView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct GameHistoryView: View {
    let actions: [GameAction]
    @Environment(\.dismiss) var dismiss
    @State private var selectedAction: GameAction?
    @State private var showingDetails = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                        ActionCard(index: index + 1, action: action)
                    }
                }
                .padding()
            }
            .background(Color(white: 0.1).ignoresSafeArea())
            .navigationTitle("Game History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct ActionCard: View {
    let index: Int
    let action: GameAction
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(actionColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text("\(index)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(action.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
            }
            
            Spacer()

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(white: 0.15))
        )
    }
    
    private var actionColor: Color {
        if action.description.contains("raised") {
            return .orange
        } else if action.description.contains("called") {
            return .blue
        } else if action.description.contains("checked") {
            return .green
        } else if action.description.contains("folded") {
            return .red
        }
        return .gray
    }
}
