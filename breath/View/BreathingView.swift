//
//  BreathingView.swift
//  breath
//
//  Completely revamped for iOS 26 & Liquid Glass
//

import SwiftUI

// MARK: - Main Breathing View
struct BreathingView: View {
    // MARK: - Environment & Data
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise
    
    // MARK: - Animation State
    @State private var breathingPhase: BreathPhase = .ready
    @State private var breathProgress: Double = 0.0
    @State private var orbScale: CGFloat = 0.65
    @State private var glowIntensity: Double = 0.0
    @State private var particleRotation: Double = 0.0
    
    // MARK: - Session State
    @State private var isActive = false
    @State private var currentRound = 0
    @State private var totalRounds: Int = 5
    @State private var phaseTimer: Timer?
    
    // MARK: - UI State
    @State private var showSettings = false
    @State private var themeColor: Color = .blue
    
    // MARK: Action Buttons
    @State private var addedRound: Bool = false
    
    enum BreathPhase: Equatable {
        case ready, inhale, hold, exhale
        
        var title: String {
            switch self {
            case .ready: return "Ready"
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            }
        }
        
        var subtitle: String {
            switch self {
            case .ready: return ""
            case .inhale: return "Fill your lungs"
            case .hold: return "Keep it steady"
            case .exhale: return "Release slowly"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Ambient background
            ambientBackground
            
            VStack(spacing: 32) {
                // Phase text
                VStack(spacing: 8) {
                    Text(breathingPhase.title)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .foregroundStyle(themeColor)
                    
                    //if breathingPhase.subtitle != "" {
                        Text(breathingPhase.subtitle)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    //}
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                //.glassBackground(tint: themeColor)
                .animation(.spring(duration: 0.5, bounce: 0.3), value: breathingPhase)
                //.glassEffect()
                
                Spacer()
                
                // Main orb
                breathingOrb
                    //.frame(height: 280)
                
                Spacer()
                
                // Rounds
                roundsIndicator
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    //.glassBackground(tint: themeColor)
                    //.glassEffect()
                
                Spacer()
            
                                
                                // Control panel
                //controlBar
                        //.padding(.bottom, 16)
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
                    Button {
                        resetSession()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .disabled(!isActive && currentRound == 0)
                    
                    Spacer()
                    
                    // Play/Pause
                    Button {
                        toggleBreathing()
                    } label: {
                        Image(systemName: isActive ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
                    }
					.frame(
						maxWidth: .infinity,
						maxHeight: .infinity,
						alignment: .center
					)
					.tint(!isActive ? themeColor : nil)
					
                    //.tint(themeColor)
                    //.glassButtonStyleProminent()
                    .sensoryFeedback(.impact(weight: .medium), trigger: isActive)
					//.frame(width: .infinity)
					
                    
                    Spacer()
                    
                    // Add round
                    Button {
                        addRound()
                        addedRound.toggle()
                    } label: {
                        Image(systemName: "plus.arrow.trianglehead.clockwise")
                            .symbolEffect(.rotate, value: addedRound)
                    }
                    .disabled(totalRounds >= 15)
            }
        }
        .sheet(isPresented: $showSettings) {
            ExerciseSettingsView()
                .environmentObject(exercise)
        }
        .onAppear(perform: setup)
        .onDisappear(perform: cleanup)
    }
    
    // MARK: - Ambient Background
    private var ambientBackground: some View {
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
            
            // Breathing glow
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
    
    // MARK: - Breathing Orb
    private var breathingOrb: some View {
        ZStack {
            // Progress ring
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
            
            // Animated particles
            ForEach(0..<0, id: \.self) { index in
                Circle()
                    .fill(themeColor.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .offset(y: 120)
                    .rotationEffect(.degrees(Double(index) * 8 + particleRotation))
                    .blur(radius: 0)
                
            }
            
            // Main breathing sphere
            ZStack {
                // Glow layers
                ForEach(0..<3, id: \.self) { layer in
                    Circle()
                        .fill(themeColor.opacity(0.15 - Double(layer) * 0.05))
                        .frame(width: 240, height: 240)
                        .blur(radius: 20 + Double(layer) * 10)
                        .scaleEffect(orbScale * (1.0 + Double(layer) * 0.1))
                }
                
                // Core orb
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
                    
                    /*
                     .shadow(
                         color: themeColor.opacity(0.3 * glowIntensity),
                         radius: 30,
                         y: 10
                     )
                     */
                
                // Center percentage
                if false && isActive {
                    Text("\(Int(breathProgress * 100))%")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
            }
            .glassEffect()
            .scaleEffect(orbScale)
            //.glassBackground(tint: themeColor, isCircle: true)
        }
    }
    
    // MARK: - Rounds Indicator
    private var roundsIndicator: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalRounds, id: \.self) { index in
                Circle()
                    .fill(index < currentRound ? themeColor : themeColor.opacity(0.25))
                    .frame(width: 8, height: 8)
                    .overlay {
                        if index == currentRound && isActive {
                            Circle()
                                .stroke(themeColor, lineWidth: 2)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .animation(.spring(duration: 0.4, bounce: 0.4), value: currentRound)
            }
        }
    }
    
    // MARK: - Setup & Lifecycle
    private func setup() {
        themeColor = Color.fromRGB(
            red: exercise.red,
            green: exercise.green,
            blue: exercise.blue
        )
        totalRounds = Int(exercise.repetitions)
        startAmbientAnimation()
    }
    
    private func cleanup() {
        phaseTimer?.invalidate()
    }
    
    private func startAmbientAnimation() {
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            particleRotation = 360
        }
    }
    
    // MARK: - Actions
    private func toggleBreathing() {
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
    
    private func resetSession() {
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
    
    private func addRound() {
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
                if self.exercise.animations {
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

// MARK: - Glass Effect Modifiers (iOS 26 Compatible)
extension View {
    @ViewBuilder
    func glassBackground(tint: Color, isCircle: Bool = false) -> some View {
        if #available(iOS 26, *) {
            if isCircle {
                self.background {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            tint.opacity(0.15),
                                            tint.opacity(0.08),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.15), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
                }
            } else {
                self.background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            tint.opacity(0.12),
                                            tint.opacity(0.06),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(.white.opacity(0.15), lineWidth: 0.5)
                        }
                        .shadow(color: .black.opacity(0.06), radius: 15, y: 6)
                }
            }
        } else {
            self.background {
                if isCircle {
                    Circle()
                        .fill(.ultraThinMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
            }
        }
    }
    
    @ViewBuilder
    func glassButtonStyle() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }
    
    @ViewBuilder
    func glassButtonStyleProminent() -> some View {
        if #available(iOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
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
