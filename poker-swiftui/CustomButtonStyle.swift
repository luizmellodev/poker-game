//
//  CustomButtonStyle.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 05/03/25.
//

import SwiftUI

struct ActionButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isDisabled: Bool
    
    init(backgroundColor: Color = .green, isDisabled: Bool = false) {
        self.backgroundColor = backgroundColor
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                backgroundColor.opacity(configuration.isPressed ? 0.5 : 1)
            )
            .cornerRadius(10)
            .foregroundColor(.white)
            .opacity(isDisabled ? 0.3 : 1)
    }
}
