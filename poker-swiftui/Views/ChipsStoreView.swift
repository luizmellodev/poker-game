import SwiftUI

struct ChipsStoreView: View {
    var onComplete: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var titleOffset: CGFloat = -400
    @State private var contentOpacity: Double = 0
    @State private var selectedPackage: ChipPackage?
    @State private var showingThankYou = false
    
    let packages = [
        ChipPackage(chips: 1000, price: 4.99, isPopular: false),
        ChipPackage(chips: 2500, price: 9.99, isPopular: true),
        ChipPackage(chips: 5000, price: 14.99, isPopular: false),
        ChipPackage(chips: 10000, price: 24.99, isPopular: false)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2),
                         Color(red: 0.05, green: 0.05, blue: 0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Chip Store")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .offset(y: titleOffset)
                
                if !showingThankYou {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(packages, id: \.chips) { package in
                                ChipPackageView(package: package, isSelected: selectedPackage?.chips == package.chips) {
                                    selectedPackage = package
                                }
                            }
                        }
                        .padding()
                    }
                    .opacity(contentOpacity)
                    
                    Button(action: {
                        guard selectedPackage != nil else { return }
                        withAnimation(.spring()) {
                            showingThankYou = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            onComplete()
                            dismiss()
                        }
                    }) {
                        HStack {
                            Text(selectedPackage == nil ? "Select a Package" : "Purchase \(selectedPackage?.formattedPrice ?? "")") 
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(selectedPackage == nil ? Color.gray.opacity(0.3) : Color.green)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .disabled(selectedPackage == nil)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Thank You!")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        if let package = selectedPackage {
                            Text("+\(package.chips) chips added")
                                .font(.headline)
                                .foregroundColor(.yellow)
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.bottom)
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

struct ChipPackageView: View {
    let package: ChipPackage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(package.chips) Chips")
                        .font(.headline)
                    
                    Text(package.formattedPrice)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if package.isPopular {
                    Text("POPULAR")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

