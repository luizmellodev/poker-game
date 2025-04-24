//
//  BotDifficulty.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

enum BotDifficulty: String, Codable, CaseIterable {
    case easy, normal, hard
    
    var description: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
}
