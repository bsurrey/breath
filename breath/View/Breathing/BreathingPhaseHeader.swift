//
//  BreathingPhaseHeader.swift
//  breath
//

import SwiftUI

struct BreathingPhaseHeader: View {
    let phase: BreathPhase
    let themeColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(phase.title)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(themeColor)

            Text(phase.subtitle)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .animation(.spring(duration: 0.5, bounce: 0.3), value: phase)
    }
}

// MARK: - Preview
struct BreathingPhaseHeader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            BreathingPhaseHeader(phase: .ready, themeColor: .mint)
            BreathingPhaseHeader(phase: .inhale, themeColor: .indigo)
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
