//
//  BreathingView.swift
//  breath
//
//  Modularized for iOS 26 & Liquid Glass-ready UI
//

import SwiftUI
import SwiftData

struct BreathingView: View {
    // MARK: - Environment & Data
    @AppStorage(SettingsKey.usePerExerciseColors) var usePerExerciseColors = true
    @AppStorage(SettingsKey.defaultCardColor) var defaultCardColorHex = DefaultCardColor.default.hexString
    @Bindable var exercise: Exercise

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
        .navigationTitle(exercise.title)
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
            ExerciseSettingsView(exercise: exercise)
        }
        .onAppear(perform: setup)
        .onDisappear(perform: cleanup)
        .onChange(of: usePerExerciseColors) { _ in
            setup()
        }
        .onChange(of: defaultCardColorHex) { _ in
            setup()
        }
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
    @MainActor
    static var previewContainer: ModelContainer = {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Exercise.self, configurations: configuration)
        return container
    }()

    @MainActor
    static var previewExercise: Exercise = {
        let context = previewContainer.mainContext
        if let existing = try? context.fetch(FetchDescriptor<Exercise>()).first {
            return existing
        }

        let defaultCard = DefaultCardColor(color: .blue)
        let defaultColor = Color.blue.toRGB()
        let exercise = Exercise(
            title: "Calm Breathing",
            breathingInDuration: 4.0,
            breathingOutDuration: 6.0,
            repetitions: 6,
            animations: true,
            red: defaultColor.red,
            green: defaultColor.green,
            blue: defaultColor.blue,
            color: defaultCard.hexString
        )
        context.insert(exercise)
        try! context.save()
        return exercise
    }()

    static var previews: some View {
        NavigationView {
            BreathingView(exercise: previewExercise)
        }
        .modelContainer(previewContainer)
        .preferredColorScheme(.light)
    }
}
