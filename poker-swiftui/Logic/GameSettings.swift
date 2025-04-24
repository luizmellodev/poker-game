//
//  GameSettings.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import Foundation
import SwiftUI

class GameSettings: ObservableObject {
    static let shared = GameSettings()
    
    @Published var gameDifficulty: GameDifficulty = .medium
    @Published private(set) var playerChips: Int
    @Published private(set) var defaultRaiseAmount: Int
    @Published private(set) var bots: [BotPlayer]
    @Published private(set) var dailyClaimsRemaining: Int
    @Published private(set) var lastClaimDate: Date?
    
    let maxBots = 3

    private init() {
        let savedChips = UserDefaults.standard.integer(forKey: "playerChips")
        self.playerChips = savedChips > 0 ? savedChips : 1000
        
        let savedRaiseAmount = UserDefaults.standard.integer(forKey: "defaultRaiseAmount")
        self.defaultRaiseAmount = savedRaiseAmount > 0 ? savedRaiseAmount : 50
        
        if let savedBots = UserDefaults.standard.data(forKey: "bots"),
           let decodedBots = try? JSONDecoder().decode([BotPlayer].self, from: savedBots) {
            self.bots = decodedBots
        } else {
            self.bots = [
                BotPlayer(name: "Diego", difficulty: .normal),
                BotPlayer(name: "Lucas", difficulty: .normal),
                BotPlayer(name: "Abraão", difficulty: .normal)
            ]
        }
        
        if let savedDifficulty = UserDefaults.standard.string(forKey: "gameDifficulty"),
           let difficulty = GameDifficulty(rawValue: savedDifficulty) {
            self.gameDifficulty = difficulty
        } else {
            self.gameDifficulty = .medium
        }
        
        let savedClaimsRemaining = UserDefaults.standard.integer(forKey: "dailyClaimsRemaining")
        let savedLastClaimDate = UserDefaults.standard.object(forKey: "lastClaimDate") as? Date
        
        if let lastDate = savedLastClaimDate {
            if !Calendar.current.isDate(lastDate, inSameDayAs: Date()) {
                self.dailyClaimsRemaining = 2
                self.lastClaimDate = Date()
            } else {
                self.dailyClaimsRemaining = savedClaimsRemaining
                self.lastClaimDate = lastDate
            }
        } else {
            self.dailyClaimsRemaining = 2
            self.lastClaimDate = Date()
        }
    }
    
    func addChips(amount: Int) {
        playerChips += amount
        UserDefaults.standard.set(playerChips, forKey: "playerChips")
    }
    
    func resetChips() {
        playerChips = 800
        UserDefaults.standard.set(playerChips, forKey: "playerChips")
    }
    
    func updateRaiseAmount(_ amount: Int) {
        defaultRaiseAmount = amount
        UserDefaults.standard.set(defaultRaiseAmount, forKey: "defaultRaiseAmount")
    }
    
    func updateBots(_ newBots: [BotPlayer]) {
        bots = newBots
        if let encoded = try? JSONEncoder().encode(bots) {
            UserDefaults.standard.set(encoded, forKey: "bots")
        }
    }
    
    func addBot(_ bot: BotPlayer) {
        guard bots.count < maxBots else { return }
        bots.append(bot)
        if let encoded = try? JSONEncoder().encode(bots) {
            UserDefaults.standard.set(encoded, forKey: "bots")
        }
    }
    
    func removeBot(at index: Int) {
        bots.remove(at: index)
        if bots.isEmpty {
            bots = [
                BotPlayer(name: "Diego", difficulty: .normal),
                BotPlayer(name: "Lucas", difficulty: .normal),
                BotPlayer(name: "Abraão", difficulty: .normal)
            ]
        }
        if let encoded = try? JSONEncoder().encode(bots) {
            UserDefaults.standard.set(encoded, forKey: "bots")
        }
    }
    
    func updatePlayerChips(_ amount: Int) {
        playerChips = amount
        UserDefaults.standard.set(playerChips, forKey: "playerChips")
    }
    
    func updateDifficulty(_ difficulty: GameDifficulty) {
        gameDifficulty = difficulty
        UserDefaults.standard.set(difficulty.rawValue, forKey: "gameDifficulty")
    }
    
    func claimDailyChips() -> Bool {
        if let lastDate = lastClaimDate,
           !Calendar.current.isDate(lastDate, inSameDayAs: Date()) {
            dailyClaimsRemaining = 2
        }
        
        guard dailyClaimsRemaining > 0 else { return false }
        
        addChips(amount: 500)
        dailyClaimsRemaining -= 1
        lastClaimDate = Date()
        
        UserDefaults.standard.set(dailyClaimsRemaining, forKey: "dailyClaimsRemaining")
        UserDefaults.standard.set(lastClaimDate, forKey: "lastClaimDate")
        
        return true
    }
}
