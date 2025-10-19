//
//  BreathingAmbientBackground.swift
//  breath
//

import SwiftUI

struct BreathingAmbientBackground: View {
    let themeColor: Color
    let glowIntensity: Double
    let orbScale: CGFloat

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    themeColor.opacity(0.06),
                    themeColor.opacity(0.12),
                    themeColor.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            themeColor.opacity(0.15 * glowIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 350
                    )
                )
                .frame(width: 700, height: 700)
                .blur(radius: 100)
                .scaleEffect(orbScale)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Preview
struct BreathingAmbientBackground_Previews: PreviewProvider {
    static var previews: some View {
        BreathingAmbientBackground(
            themeColor: .blue,
            glowIntensity: 1.0,
            orbScale: 0.9
        )
        .previewLayout(.fixed(width: 300, height: 300))
    }
}
