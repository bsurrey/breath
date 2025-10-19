//
//  BreathingOrb.swift
//  breath
//

import SwiftUI

struct BreathingOrb: View {
    let themeColor: Color
    let orbScale: CGFloat
    let breathProgress: Double
    let glowIntensity: Double
    let particleRotation: Double
    let isActive: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(themeColor.opacity(0.12), lineWidth: 0)
                .frame(width: 300, height: 300)

            Circle()
                .trim(from: 0, to: breathProgress)
                .stroke(
                    themeColor,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(-90))

            BreathingOrbParticles(
                themeColor: themeColor,
                particleRotation: particleRotation
            )

            BreathingOrbCore(
                themeColor: themeColor,
                orbScale: orbScale,
                glowIntensity: glowIntensity,
                isActive: isActive,
                breathProgress: breathProgress
            )
        }
    }
}

private struct BreathingOrbParticles: View {
    let themeColor: Color
    let particleRotation: Double

    var body: some View {
        ForEach(0..<0, id: \.self) { index in
            Circle()
                .fill(themeColor.opacity(0.3))
                .frame(width: 8, height: 8)
                .offset(y: 120)
                .rotationEffect(.degrees(Double(index) * 8 + particleRotation))
        }
        .blur(radius: 0)
    }
}

private struct BreathingOrbCore: View {
    let themeColor: Color
    let orbScale: CGFloat
    let glowIntensity: Double
    let isActive: Bool
    let breathProgress: Double

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { layer in
                Circle()
                    .fill(themeColor.opacity(0.15 - Double(layer) * 0.05))
                    .frame(width: 240, height: 240)
                    .blur(radius: 20 + Double(layer) * 10)
                    .scaleEffect(orbScale * (1.0 + Double(layer) * 0.1))
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            themeColor.opacity(0.9),
                            themeColor.opacity(0.75),
                            themeColor.opacity(0.6)
                        ],
                        center: UnitPoint(x: 0.4, y: 0.4),
                        startRadius: 0,
                        endRadius: 120
                    )
                )
                .frame(width: 240, height: 240)
                .overlay {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.25),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .center
                            )
                        )
                }
                .glassEffect()

            if false && isActive {
                Text("\(Int(breathProgress * 100))%")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
            }
        }
        .scaleEffect(orbScale)
    }
}

// MARK: - Preview
struct BreathingOrb_Previews: PreviewProvider {
    static var previews: some View {
        BreathingOrb(
            themeColor: .cyan,
            orbScale: 0.8,
            breathProgress: 0.6,
            glowIntensity: 0.8,
            particleRotation: 180,
            isActive: true
        )
        .padding()
        //.background(Color.black.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
