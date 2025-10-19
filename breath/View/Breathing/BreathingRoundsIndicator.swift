//
//  BreathingRoundsIndicator.swift
//  breath
//

import SwiftUI

struct BreathingRoundsIndicator: View {
    let totalRounds: Int
    let currentRound: Int
    let isActive: Bool
    let themeColor: Color

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalRounds, id: \.self) { index in
                Circle()
                    .fill(index < currentRound ? themeColor : themeColor.opacity(0.25))
                    .frame(width: 8, height: 8)
                    .overlay(activeOverlay(for: index))
                    .animation(.spring(duration: 0.4, bounce: 0.4), value: currentRound)
            }
        }
    }

    @ViewBuilder
    private func activeOverlay(for index: Int) -> some View {
        if index == currentRound && isActive {
            Circle()
                .stroke(themeColor, lineWidth: 2)
                .frame(width: 16, height: 16)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview
struct BreathingRoundsIndicator_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            BreathingRoundsIndicator(
                totalRounds: 5,
                currentRound: 2,
                isActive: true,
                themeColor: .orange
            )

            BreathingRoundsIndicator(
                totalRounds: 8,
                currentRound: 7,
                isActive: false,
                themeColor: .blue
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
