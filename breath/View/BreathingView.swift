//
//  BreathingView.swift
//  breath
//
//  Created by Benjamin Surrey on 06.05.23.
//

import SwiftUI
import AudioToolbox

struct BreathingView: View {
    // Circle appearance
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    // States
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isBreathingIn = true
    @State private var phaseProgress: Double = 0 // 0..1 within current phase

    // Timer
    @State private var timer: ResumableTimer?
    @State private var remainingRounds: Int = 5
    @State private var remainingTimeForThisPhase: Double = 0 // tenths of a second

    // Data
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise

    // Ripples
    @State private var rippleOpacities: [Double] = [0.6, 0.8, 1.0]
    @State private var rippleScales: [CGFloat] = [0.5, 0.5, 0.5]

    // Settings
    @State private var showSheet = false

    // Design
    @State private var themeColor: Color = .black

    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 0.9 // minScale + 0.4

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if isRunning {
                    Text(isBreathingIn ? "Breathe in" : "Breathe out")
                        .font(.title)
                        .fontWeight(.medium)
                        .accessibilityLabel(isBreathingIn ? "Breathe in" : "Breathe out")
                }
            }
            .frame(height: 44)

            ZStack {
                if !isRunning {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(themeColor, lineWidth: 5)
                            .scaleEffect(rippleScales[index])
                            .opacity(isRunning ? 0 : rippleOpacities[index])
                            .animation(.easeOut(duration: 5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index)), value: rippleScales[index])
                            .onAppear {
                                rippleScales[index] = 1.0
                                rippleOpacities[index] = 0.0
                            }
                            .frame(width: 300, height: 300)
                    }
                }

                ZStack {
                    // Progress ring
                    Circle()
                        .stroke(themeColor.opacity(0.25), lineWidth: 10)
                        .frame(width: 280, height: 280)
                    Circle()
                        .trim(from: 0, to: CGFloat(phaseProgress))
                        .stroke(themeColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 280, height: 280)
                        .animation(.linear(duration: 0.1), value: phaseProgress)

                    // Core breathing circle
                    Circle()
                        .fill(themeColor)
                        .frame(width: 220, height: 220)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .animation(exercise.animations ? .easeInOut(duration: 0.2) : .none, value: scale)
                        .accessibilityHidden(true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 360)
            .padding(.vertical, 24)

            Text("\(remainingRounds) Rounds")
                .font(.title3)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 28)
                .accessibilityLabel("Rounds remaining: \(remainingRounds)")

            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 24) {
                Button(action: stop) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 32))
                }
                .accessibilityLabel("Stop")

                Spacer()

                Button(action: {
                    if !isRunning && !isPaused {
                        startExercise()
                    } else if isRunning {
                        pauseTimer()
                    } else if isPaused {
                        resume()
                    }
                }) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(themeColor)
                }
                .accessibilityLabel(isRunning ? "Pause" : "Play")

                Spacer()

                Button(action: addRound) {
                    Image(systemName: "goforward.plus")
                        .font(.system(size: 32))
                }
                .accessibilityLabel("Add round")
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial)
        }
        .navigationTitle(exercise.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showSheet.toggle() }) {
                    Label { Text("Settings") } icon: { Image(systemName: "info.circle") }
                }
                .foregroundColor(themeColor)
                .accessibilityLabel("Settings")
            }
        }
        .sheet(isPresented: $showSheet) {
            ExerciseSettingsView()
                .environmentObject(exercise)
        }
        .onAppear {
            themeColor = Color.fromRGB(red: exercise.red, green: exercise.green, blue: exercise.blue)
            initialize()
            timer = ResumableTimer(interval: 0.1) { run() }
        }
        .onDisappear { destruction() }
    }

    // MARK: - Timer Tick
    func run() {
        guard isRunning else { return }

        remainingTimeForThisPhase = max(remainingTimeForThisPhase - 1, 0)
        let totalPhase = max((isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration) * 10, 1)
        phaseProgress = 1 - (remainingTimeForThisPhase / totalPhase)

        if remainingTimeForThisPhase == 0 {
            // Phase complete -> toggle breath direction or finish round
            isBreathingIn.toggle()

            if isBreathingIn {
                // Completed an OUT phase -> round finished
                remainingRounds = max(remainingRounds - 1, 0)
            }

            if remainingRounds == 0 {
                stop()
                return
            }

            remainingTimeForThisPhase = (isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration) * 10
            phaseProgress = 0
        }

        let total = max((isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration) * 10, 1)
        let newScale = getScale(remainingTime: remainingTimeForThisPhase, totalTime: total, isBreathingIn: isBreathingIn)
        withAnimation(exercise.animations ? .easeInOut(duration: 0.1) : .none) {
            scale = newScale
        }
    }

    // MARK: - Helpers
    func getScale(remainingTime: Double, totalTime: Double, isBreathingIn: Bool) -> CGFloat {
        let remaining = max(remainingTime - 1, 0)
        let delta = maxScale - minScale // 0.4
        if totalTime <= 0 { return minScale }
        if isBreathingIn {
            let progress = (totalTime - remaining) / totalTime
            return min(max(minScale + delta * progress, minScale), maxScale)
        } else {
            let progress = remaining / totalTime
            return min(max(minScale + delta * progress, minScale), maxScale)
        }
    }

    func initialize() {
        remainingRounds = max(Int(exercise.repetitions), 0)
        remainingTimeForThisPhase = max(exercise.breathingInDuration * 10, 0)
        isPaused = false
        isRunning = false
        isBreathingIn = true
        phaseProgress = 0

        scale = minScale
        opacity = 1.0
    }

    func startExercise() {
        isRunning = true
        isPaused = false
        remainingTimeForThisPhase = (isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration) * 10
        timer?.start()
    }

    func reset() {
        timer?.reset()
        initialize()
    }

    func addRound() {
        remainingRounds += 1
    }

    func pauseTimer() {
        timer?.pause()
        isRunning = false
        isPaused = true
    }

    func stop() {
        timer?.invalidate()
        initialize()
    }

    func resume() {
        isRunning = true
        isPaused = false
        timer?.start() // ensure timer fires again
    }

    func destruction() {
        timer?.invalidate()
    }
}

struct BreathingView_Previews: PreviewProvider {
    static var previews: some View {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newEx = Exercise(context: viewContext)
        newEx.uuid = UUID()
        newEx.animations = true
        newEx.breathingInDuration = 4.0
        newEx.breathingOutDuration = 7.0
        newEx.color = ".black"
        newEx.createdTime = Date()
        newEx.favorite = false
        newEx.repetitions = 5
        newEx.updatedTime = Date()
        newEx.title = "4 - 7 - 4"
        
        let rgb = Color.green.toRGB()
        newEx.red = rgb.red
        newEx.blue = rgb.blue
        newEx.green = rgb.green
        
        return NavigationView {
            BreathingView(exercise: newEx)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
