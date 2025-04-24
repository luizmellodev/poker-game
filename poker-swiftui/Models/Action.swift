//
//  Action.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import Foundation

enum Action {
    case fold
    case check
    case call
    case raise(Int)
    
    var description: String {
        switch self {
        case .fold:
            return "Fold"
        case .check:
            return "Check"
        case .call:
            return "Call"
        case .raise(let amount):
            return "Raise \(amount)"
        }
    }
}
