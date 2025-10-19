//
//  BreathingView.swift
//  breath
//
//  Modularized for iOS 26 & Liquid Glass-ready UI
//

import SwiftUI

struct BreathingView: View {
    // MARK: - Environment & Data
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise

    // MARK: - Animation State
    @State var breathingPhase: BreathPhase = .ready
    @State var breathProgress: Double = 0.0
    @State var orbScale: CGFloat = 0.65
    @State var glowIntensity: Double = 0.0
    @State var particleRotation: Double = 0.0

    // MARK: - Session State
    @State var isActive = false
    @State var currentRound = 0
    @State var totalRounds: Int = 5
    @State var phaseTimer: Timer?

    // MARK: - UI State
    @State var showSettings = false
    @State var themeColor: Color = .blue
    @State var addedRound = false

    var body: some View {
        ZStack {
            BreathingAmbientBackground(
                themeColor: themeColor,
                glowIntensity: glowIntensity,
                orbScale: orbScale
            )

            VStack(spacing: 32) {
                BreathingPhaseHeader(phase: breathingPhase, themeColor: themeColor)

                Spacer()

                BreathingOrb(
                    themeColor: themeColor,
                    orbScale: orbScale,
                    breathProgress: breathProgress,
                    glowIntensity: glowIntensity,
                    particleRotation: particleRotation,
                    isActive: isActive
                )

                Spacer()

                BreathingRoundsIndicator(
                    totalRounds: totalRounds,
                    currentRound: currentRound,
                    isActive: isActive,
                    themeColor: themeColor
                )
                .padding(.horizontal, 28)
                .padding(.vertical, 16)

                Spacer()
            }
            .padding(.vertical, 20)
        }
        .navigationTitle(exercise.title ?? "Breathe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 44, height: 44)
                }
                .tint(themeColor)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                resetButton

                Spacer()

                playPauseButton
                    .frame(maxWidth: .infinity)

                Spacer()

                addRoundButton
            }
        }
        .sheet(isPresented: $showSettings) {
            ExerciseSettingsView()
                .environmentObject(exercise)
        }
        .onAppear(perform: setup)
        .onDisappear(perform: cleanup)
    }
}

// MARK: - Liquid Glass Controls
private extension BreathingView {
    @ViewBuilder
    var resetButton: some View {
        Button {
            resetSession()
        } label: {
            Image(systemName: "xmark")
        }
        .disabled(!isActive && currentRound == 0)
        .controlSize(.large)
        .buttonStyle(.glassProminent)
        .tint(themeColor)
    }

    @ViewBuilder
    var playPauseButton: some View {
        Button {
            toggleBreathing()
        } label: {
            Image(systemName: isActive ? "pause.fill" : "play.fill")
                .contentTransition(.symbolEffect(.replace))
        }
        .controlSize(.large)
        .sensoryFeedback(.impact(weight: .medium), trigger: isActive)
        .buttonStyle(.glassProminent)
        .tint(themeColor)
    }

    @ViewBuilder
    var addRoundButton: some View {
        Button {
            addRound()
            addedRound.toggle()
        } label: {
            Image(systemName: "plus.arrow.trianglehead.clockwise")
                .symbolEffect(.rotate, value: addedRound)
        }
        .disabled(totalRounds >= 15)
        .controlSize(.large)
        .buttonStyle(.glass)
        .tint(themeColor)
    }
}

// MARK: - Preview
struct BreathingView_Previews: PreviewProvider {
    static var previews: some View {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let exercise = Exercise(context: viewContext)
        exercise.uuid = UUID()
        exercise.animations = true
        exercise.breathingInDuration = 4.0
        exercise.breathingOutDuration = 6.0
        exercise.color = ".blue"
        exercise.createdTime = Date()
        exercise.favorite = false
        exercise.repetitions = 5
        exercise.updatedTime = Date()
        exercise.title = "Calm Breathing"

        let rgb = Color.blue.toRGB()
        exercise.red = rgb.red
        exercise.blue = rgb.blue
        exercise.green = rgb.green

        return NavigationView {
            BreathingView(exercise: exercise)
                .environment(\.managedObjectContext, viewContext)
        }
        .preferredColorScheme(.light)
    }
}
