//
//  Player.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import Foundation

class Player: Identifiable {
    var id = UUID()
    var name: String
    var hand: [Card] = []
    var isFolded = false
    var currentAction: Action?
    var chips: Int
    var hasActedThisRound: Bool = false

    init(name: String, chips: Int = 1000) {
        self.name = name
        self.chips = chips
    }
    
    func reset() {
        isFolded = false
        currentAction = nil
    }
}
