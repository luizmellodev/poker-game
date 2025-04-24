//
//  Card.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import Foundation

struct Card: Identifiable, Hashable {
    var id = UUID()
    var rank: String
    var suit: String
}
