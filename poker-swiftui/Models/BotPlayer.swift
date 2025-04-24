//
//  BotPlayer.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import Foundation

struct BotPlayer: Codable, Identifiable {
    let id = UUID()
    var name: String
    var difficulty: BotDifficulty
}
