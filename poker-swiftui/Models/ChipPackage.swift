//
//  ChipPackage.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 22/03/25.
//


import SwiftUI

struct ChipPackage {
    let chips: Int
    let price: Double
    let isPopular: Bool
    
    var formattedPrice: String {
        String(format: "R$ %.2f", price)
    }
}
