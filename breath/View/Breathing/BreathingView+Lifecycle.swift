//
//  BreathingView+Lifecycle.swift
//  breath
//

import SwiftUI
import UIKit

@MainActor
extension BreathingView {
    // MARK: - Setup & Lifecycle
    func setup() {
        let color: Color
        if usePerExerciseColors {
            color = Color.fromRGB(
                red: exercise.red,
                green: exercise.green,
                blue: exercise.blue
            )
        } else {
            color = DefaultCardColor(hex: defaultCardColorHex).color
        }

        themeColor = color
        totalRounds = exercise.repetitions
        startAmbientAnimation()
    }

    func cleanup() {
        phaseTimer?.invalidate()
    }

    private func startAmbientAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            particleRotation = 360
        }
    }

    // MARK: - Actions
    func toggleBreathing() {
        if isActive {
            pauseBreathing()
        } else {
            startBreathing()
        }
    }

    private func startBreathing() {
        isActive = true
        if breathingPhase == .ready {
            currentRound = 0
            breathingPhase = .inhale
        }
        animateBreathCycle()
    }

    private func pauseBreathing() {
        isActive = false
        phaseTimer?.invalidate()
    }

    func resetSession() {
        isActive = false
        phaseTimer?.invalidate()
        currentRound = 0
        breathingPhase = .ready

        withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
            breathProgress = 0
            orbScale = 0.65
            glowIntensity = 0
        }
    }

    func addRound() {
        totalRounds += 1

        #if os(iOS)
        if exercise.animations {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        #endif
    }

    // MARK: - Breathing Animation
    private func animateBreathCycle() {
        guard isActive else { return }

        let inhale = max(exercise.breathingInDuration, 1.0)
        let exhale = max(exercise.breathingOutDuration, 1.0)
        let hold = 1.5

        switch breathingPhase {
        case .ready:
            breathingPhase = .inhale
            animateBreathCycle()

        case .inhale:
        withAnimation(.spring(duration: inhale, bounce: 0.15)) {
            orbScale = 0.95
            glowIntensity = 1.0
            breathProgress = 1.0
        }

        phaseTimer = Timer.scheduledTimer(withTimeInterval: inhale, repeats: false) { _ in
            breathingPhase = .hold
            animateBreathCycle()
        }

        case .hold:
            withAnimation(.spring(duration: hold, bounce: 0)) {
                orbScale = 0.95
                glowIntensity = 0.85
            }

        phaseTimer = Timer.scheduledTimer(withTimeInterval: hold, repeats: false) { _ in
            breathingPhase = .exhale
            animateBreathCycle()
        }

        case .exhale:
            withAnimation(.spring(duration: exhale, bounce: 0.15)) {
                orbScale = 0.65
                glowIntensity = 0.2
                breathProgress = 0
            }

        phaseTimer = Timer.scheduledTimer(withTimeInterval: exhale, repeats: false) { _ in
            currentRound += 1

                #if os(iOS)
                if exercise.animations {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                }
                #endif

                if currentRound >= totalRounds {
                    completeSession()
                } else {
                    breathingPhase = .inhale
                    animateBreathCycle()
                }
            }
        }
    }

    private func completeSession() {
        isActive = false
        breathingPhase = .ready

        withAnimation(.spring(duration: 1.0, bounce: 0.35)) {
            breathProgress = 0
            orbScale = 0.65
            glowIntensity = 0
        }

        #if os(iOS)
        if exercise.animations {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        #endif
    }
}
