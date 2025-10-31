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
    
    @State var phaseStartDate: Date? = nil
    @State var phaseElapsed: TimeInterval = 0
    @State var currentPhaseDuration: TimeInterval = 0
    
    // MARK: - Session State
    @State var isActive = false
    @State var currentRound = 0
    @State var totalRounds: Int = 5
    
    @State var animationTimer: Timer? = nil
    private let holdDuration: TimeInterval = 1.5
    
    // MARK: - UI State
    @State var showSettings = false
    @State var themeColor: Color = .blue
    @State var addedRound = false
    @State var removedRound = false
    
    // MARK: - Timing & Control Helpers
    func durationForCurrentPhase() -> TimeInterval {
        switch breathingPhase {
        case .ready:
            return 1.0
        case .inhale:
            return exercise.breathingInDuration
        case .hold:
            return holdDuration
        case .exhale:
            return exercise.breathingOutDuration
        default:
            return 0.0
        }
    }
    
    func startPhaseIfNeeded() {
        // Initialize timing values when (re)starting a phase
        if phaseStartDate == nil {
            currentPhaseDuration = durationForCurrentPhase()
            phaseStartDate = Date().addingTimeInterval(-phaseElapsed)
        }
        startAnimationTimer()
    }
    
    func startAnimationTimer() {
        animationTimer?.invalidate()
        guard isActive else { return }
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            tick()
        }
        RunLoop.main.add(animationTimer!, forMode: .common)
    }
    
    func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func tick() {
        guard isActive, let start = phaseStartDate else { return }
        let elapsed = Date().timeIntervalSince(start)
        phaseElapsed = max(0, min(elapsed, currentPhaseDuration))
        let phaseProgress = currentPhaseDuration > 0 ? phaseElapsed / currentPhaseDuration : 1
        updateVisualsForCurrentPhase(phaseProgress: phaseProgress)
        
        if phaseElapsed >= currentPhaseDuration {
            advancePhase()
        }
    }
    
    func advancePhase() {
        // Reset timing for next phase but keep play state
        phaseStartDate = nil
        phaseElapsed = 0
        switch breathingPhase {
        case .ready:
            breathingPhase = .inhale
        case .inhale:
            breathingPhase = .hold
        case .hold:
            breathingPhase = .exhale
        case .exhale:
            // Increment rounds when a full inhale+exhale completes
            currentRound = min(currentRound + 1, totalRounds)
            let isFinalRound = currentRound >= totalRounds
            handleRoundCompletion(isFinal: isFinalRound)
            if isFinalRound {
                isActive = false
                stopAnimationTimer()
                // Reset to ready for next session
                breathingPhase = .ready
                handleSessionCompletion()
                updateVisualsForCurrentPhase()
                return
            } else {
                breathingPhase = .inhale
            }
        default:
            isActive = false
            stopAnimationTimer()
            return
        }
        // Start next phase timing
        currentPhaseDuration = durationForCurrentPhase()
        updateVisualsForCurrentPhase()
        startPhaseIfNeeded()
    }
    
    func pauseSession() {
        // Stop timers but do not reset progress; keep phaseElapsed and breathProgress
        stopAnimationTimer()
    }
    
    func resumeSession() {
        // Resume from the same point by setting a start date offset by already elapsed time
        phaseStartDate = Date().addingTimeInterval(-phaseElapsed)
        startAnimationTimer()
    }
    
    func updateVisualsForCurrentPhase(phaseProgress: Double? = nil) {
        let rawProgress: Double
        if let phaseProgress {
            rawProgress = max(0.0, min(phaseProgress, 1.0))
        } else if currentPhaseDuration > 0 {
            rawProgress = max(0.0, min(phaseElapsed / currentPhaseDuration, 1.0))
        } else {
            rawProgress = 1.0
        }
        
        let effectiveProgress: Double
        switch breathingPhase {
        case .ready:
            effectiveProgress = 0.0
        case .inhale:
            effectiveProgress = rawProgress
        case .hold:
            effectiveProgress = 1.0
        case .exhale:
            effectiveProgress = 1.0 - rawProgress
        default:
            effectiveProgress = 0.0
        }
        
        breathProgress = effectiveProgress
        
        let baseScale: CGFloat = 0.65
        let peakScale: CGFloat = 0.95
        let baseGlow: Double = 0.2
        let peakGlow: Double = 1.0
        
        switch breathingPhase {
        case .ready:
            orbScale = baseScale
            glowIntensity = 0.0
        case .inhale, .exhale:
            let factor = effectiveProgress
            orbScale = baseScale + (peakScale - baseScale) * CGFloat(factor)
            glowIntensity = baseGlow + (peakGlow - baseGlow) * factor
        case .hold:
            orbScale = peakScale
            glowIntensity = 0.85
        default:
            orbScale = baseScale
            glowIntensity = 0.0
        }
    }
    
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
        .toolbar{
            ToolbarItem(id: "reset", placement: .bottomBar) {
                resetButton
            }
            ToolbarSpacer(placement: .bottomBar)
            ToolbarItem(id:"playPause", placement: .bottomBar) {
                playPauseButton
            }
            ToolbarSpacer(placement: .bottomBar)
            
            ToolbarItem(id: "removeRound", placement: .bottomBar) {
                removeRoundButton
            }
            ToolbarItem(id: "addRound", placement: .bottomBar) {
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
            // TODO: Break icon from music playback
            Image(systemName: "stop.fill")
        }
        // TODO: should only be disabled if not started but should also be possible when paused to reset
        .disabled(!isActive && currentRound == 0)
        .controlSize(.large)
        //.buttonStyle(.glassProminent)
        .tint(themeColor)
    }
    
    @ViewBuilder
    var playPauseButton: some View {
        Button {
            toggleBreathing()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isActive ? "pause.fill" : "play.fill")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: isActive)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
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
        .tint(themeColor)
    }
    
    
    @ViewBuilder
    var removeRoundButton: some View {
        Button {
            removeRound()
            removedRound.toggle()
        } label: {
            Image(systemName: "minus.arrow.trianglehead.counterclockwise")
                .symbolEffect(.rotate, value: removedRound)
        }
        .disabled(totalRounds <= 5)
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
