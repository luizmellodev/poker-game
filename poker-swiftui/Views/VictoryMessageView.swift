//
//  VictoryMessageView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct VictoryMessageView: View {
    let winnerName: String
    var didPlayerWin: Bool { winnerName == "You" }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            VStack(spacing: 20) {
                Text(didPlayerWin ? "You Won!" : "You lose :/")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(didPlayerWin ? .green : .red)
                
                Text(didPlayerWin ? "Congratulations!" : "\(winnerName) wins!")
                    .font(.title2)
                    .foregroundColor(.white)
                
                if !didPlayerWin {
                    Text("Better luck next time!")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .padding(40)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(radius: 10)
        }
    }
}
