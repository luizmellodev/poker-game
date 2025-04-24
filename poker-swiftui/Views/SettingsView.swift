//
//  SettingsView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameSettings = GameSettings.shared
    @State private var showingAddBot = false
    @State private var selectedTab = 0
    
    private let tabs = ["Game", "Bots", "Account"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(red: 0.1, green: 0.1, blue: 0.2),
                             Color(red: 0.05, green: 0.05, blue: 0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Custom tab bar
                    HStack {
                        ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedTab = index
                                }
                            }) {
                                Text(tab)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedTab == index ? .white : .gray)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        selectedTab == index ?
                                            Color.blue.opacity(0.3) :
                                            Color.clear
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Content
                    ScrollView {
                        VStack(spacing: 25) {
                            switch selectedTab {
                            case 0:
                                gameSettingsView
                            case 1:
                                botsSettingsView
                            case 2:
                                accountSettingsView
                            default:
                                EmptyView()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddBot) {
            AddBotView()
        }
    }
    
    private var gameSettingsView: some View {
        VStack(spacing: 20) {
            settingsCard(title: "Default Raise") {
                Stepper(
                    "$\(gameSettings.defaultRaiseAmount)",
                    value: Binding(
                        get: { gameSettings.defaultRaiseAmount },
                        set: { gameSettings.updateRaiseAmount($0) }
                    ),
                    in: 20...200,
                    step: 10
                )
                .foregroundColor(.white)
            }
            
            settingsCard(title: "Game Difficulty") {
                Picker("Difficulty", selection: $gameSettings.gameDifficulty) {
                    ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.rawValue).tag(difficulty)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
    
    private var botsSettingsView: some View {
        VStack(spacing: 15) {
            ForEach(gameSettings.bots) { bot in
                botCard(bot: bot)
            }
            
            Button(action: {
                showingAddBot = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Bot")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(gameSettings.bots.count >= gameSettings.maxBots ? 0.1 : 0.3))
                .cornerRadius(12)
            }
            .disabled(gameSettings.bots.count >= gameSettings.maxBots)
        }
    }
    
    private var accountSettingsView: some View {
        VStack(spacing: 20) {
            settingsCard(title: "Current Balance") {
                Text("$\(gameSettings.playerChips)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.green)
            }
            
            Button(action: {
                gameSettings.resetChips()
            }) {
                Text("Reset to $1,000")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.3))
                    .cornerRadius(12)
            }
        }
    }
    
    private func settingsCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func botCard(bot: BotPlayer) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bot.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(bot.difficulty.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: {
                if let index = gameSettings.bots.firstIndex(where: { $0.id == bot.id }) {
                    gameSettings.removeBot(at: index)
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
