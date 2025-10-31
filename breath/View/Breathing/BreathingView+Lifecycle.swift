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
        let resolvedColor: Color
        if usePerExerciseColors {
            if !exercise.color.isEmpty {
                resolvedColor = DefaultCardColor(hex: exercise.color).color
            } else {
                resolvedColor = Color.fromRGB(
                    red: exercise.red,
                    green: exercise.green,
                    blue: exercise.blue
                )
            }
        } else {
            resolvedColor = DefaultCardColor(hex: defaultCardColorHex).color
        }

        themeColor = resolvedColor
        totalRounds = max(1, min(exercise.repetitions, 15))
        currentPhaseDuration = durationForCurrentPhase()
        updateVisualsForCurrentPhase()
        if isActive {
            startPhaseIfNeeded()
        }
        startAmbientAnimation()
    }

    func cleanup() {
        isActive = false
        stopAnimationTimer()
        phaseStartDate = nil
    }

    private func startAmbientAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            particleRotation = 360
        }
    }

    // MARK: - Actions
    func toggleBreathing() {
        if isActive {
            isActive = false
            pauseSession()
        } else {
            isActive = true
            if phaseStartDate == nil && phaseElapsed == 0 && breathProgress == 0 {
                startPhaseIfNeeded()
            } else {
                resumeSession()
            }
        }
    }

    func resetSession() {
        isActive = false
        breathingPhase = .ready
        currentRound = 0
        phaseStartDate = nil
        phaseElapsed = 0
        breathProgress = 0
        currentPhaseDuration = durationForCurrentPhase()
        stopAnimationTimer()
        withAnimation(.spring(duration: 0.6, bounce: 0.25)) {
            orbScale = 0.65
            glowIntensity = 0.0
        }
        particleRotation = 0.0
        updateVisualsForCurrentPhase()
    }

    func addRound() {
        let nextValue = min(totalRounds + 1, 15)
        guard nextValue != totalRounds else { return }
        totalRounds = nextValue

        #if os(iOS)
        if exercise.animations {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        #endif
    }

    // MARK: - Feedback hooks
    func handleRoundCompletion(isFinal: Bool) {
        #if os(iOS)
        guard exercise.animations else { return }
        if isFinal {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        #endif
    }

    func handleSessionCompletion() {
        currentPhaseDuration = durationForCurrentPhase()
        phaseStartDate = nil
        phaseElapsed = 0
        withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
            breathProgress = 0
            orbScale = 0.65
            glowIntensity = 0.0
        }
        particleRotation = 0.0
        updateVisualsForCurrentPhase()
    }
}
