//
//  AdView.swift
//  poker-swiftui
//
//  Created by Luiz Mello on 06/03/25.
//

import SwiftUI

struct AdView: View {
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    @State private var showThankYou = false
    @State private var titleOffset: CGFloat = -400
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2),
                         Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text("Get More Chips")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                
                if !showThankYou {
                    // Content
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Watch a quick ad to get 1,000 chips!")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Text("Hard mode requires watching ads to get more chips.\nYou can change the difficulty in settings.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }
                    .opacity(contentOpacity)
                    
                    // Watch button
                    Button(action: {
                        withAnimation(.spring()) {
                            isLoading = true
                        }
                        // Simulate ad watching
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.spring()) {
                                showThankYou = true
                                isLoading = false
                            }
                            // Dismiss after showing thank you
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onComplete()
                                dismiss()
                            }
                        }
                    }) {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                            }
                            
                            Text(isLoading ? "Loading..." : "Watch Ad")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .opacity(contentOpacity)
                    }
                    .disabled(isLoading)
                } else {
                    // Thank you message
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Thank You!")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Text("+1,000 chips added")
                            .font(.headline)
                            .foregroundColor(.yellow)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            withAnimation(.spring(dampingFraction: 0.7).delay(0.3)) {
                titleOffset = 0
            }
            withAnimation(.easeOut.delay(0.5)) {
                contentOpacity = 1
            }
        }
    }
}
