//
//  AddBotView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct AddBotView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameSettings = GameSettings.shared
    @State private var botName = ""
    @State private var selectedDifficulty = BotDifficulty.normal
    @State private var showingMaxBotsAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Bot Name", text: $botName)
                
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(BotDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.description)
                    }
                }
            }
            .navigationTitle("Add Bot")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    if gameSettings.bots.count < gameSettings.maxBots {
                        saveBot()
                        dismiss()
                    } else {
                        showingMaxBotsAlert = true
                    }
                }
                .disabled(botName.isEmpty)
            )
            .alert("Maximum Bots Reached", isPresented: $showingMaxBotsAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("You can't add more than \(gameSettings.maxBots) bots.")
            }
        }
    }
    
    private func saveBot() {
        let newBot = BotPlayer(name: botName, difficulty: selectedDifficulty)
        gameSettings.addBot(newBot)
    }
}
