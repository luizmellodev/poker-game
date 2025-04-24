//
//  CustomSliderStyle.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 15/03/25.
//

import SwiftUI

struct SliderConfig {
    let thumbSize: CGFloat = 28
    let lineWidth: CGFloat = 8
    let cornerRadius: CGFloat = 4
}

struct CustomSliderStyle: ViewModifier {
    @Binding var value: Double
    let range: ClosedRange<Double>
    private let config = SliderConfig()
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.3))
                    .frame(height: config.lineWidth)
                    .cornerRadius(config.cornerRadius)
                
                Rectangle()
                    .foregroundColor(.green)
                    .frame(width: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)),
                           height: config.lineWidth)
                    .cornerRadius(config.cornerRadius)
                
                Circle()
                    .fill(.white)
                    .frame(width: config.thumbSize, height: config.thumbSize)
                    .shadow(radius: 3)
                    .offset(x: geometry.size.width * CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) - config.thumbSize/2)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                let width = geometry.size.width - config.thumbSize
                                let dragValue = gesture.location.x - config.thumbSize/2
                                let ratio = dragValue / width
                                let newValue = range.lowerBound + (range.upperBound - range.lowerBound) * Double(ratio)
                                value = min(range.upperBound, max(range.lowerBound, newValue))
                            }
                    )
            }
            .frame(height: config.thumbSize)
        }
        .frame(height: config.thumbSize)
    }
}

extension View {
    func customSlider(value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        self.modifier(CustomSliderStyle(value: value, range: range))
    }
}
