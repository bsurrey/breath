//
//  BreathingView.swift
//  breath
//
//  Created by Benjamin Surrey on 06.05.23.
//

import SwiftUI
import AudioToolbox

struct BreathingView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    @State private var isBreathingIn = true
    @State private var timer: Timer?
    
    @State private var animateCircle = true
    @State private var themeColor: Color = .blue

    @State private var breathsRemaining: Int = 5
    @State private var timeRemaining: Double = 4.0
    @State private var isPlaying = false
    @State private var isFirstRound = true
    
    @State private var rippleOpacities: [Double] = [0.2, 0.4, 0.6]
    @State private var rippleScales: [CGFloat] = [0.5, 0.5, 0.5]
    
    @State private var showSheet = false
    
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise
    
    
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Text(isBreathingIn ? "Breathe In" : "Breathe Out")
                        .font(.title)
                        .padding()
                    
                    ZStack {
                        if !isPlaying {
                            ForEach(0..<3) { index in
                                Circle()
                                    .stroke(themeColor, lineWidth: 2)
                                    .scaleEffect(rippleScales[index])
                                    .opacity(rippleOpacities[index])
                                    .animation(Animation.easeOut(duration: 2).repeatForever(autoreverses: true).delay(Double(index) * 0.8))
                                    .onAppear {
                                        rippleScales[index] = 1.0
                                        rippleOpacities[index] = 0.0
                                    }
                            }
                        }
                        
                        Circle()
                            .fill(themeColor)
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .animation(exercise.animations ? .easeInOut(duration: isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration) : nil)
                        
                        
                        Text(String(format: "%.f", timeRemaining))
                            .font(.largeTitle)
                            .padding()
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Text("Remaining rounds: \(breathsRemaining)")
                        .font(.title2)
                        .padding()
                    
                    HStack {
                        Button(action: {
                            isPlaying.toggle()
                            if isPlaying {
                                startBreathing()
                            } else {
                                timer?.invalidate()
                            }
                        }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(themeColor)
                        }
                    }
                    .sheet(isPresented: $showSheet) {
                        SliderSheetView()
                            .environmentObject(exercise)
                    }
                    .padding()
                }
            }
            .navigationTitle(exercise.title ?? "")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSheet.toggle()
                    }) {
                        Label {
                            Text("Settings")
                        } icon: {
                            Image(systemName: "info.circle")
                        }
                        
                    }
                }
            }
        }
    }
    
    func startBreathing() {
        breathsRemaining = Int(exercise.repetitions)
        timeRemaining = isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration
        timer?.invalidate()
        
        var stepper = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeRemaining -= 1
            
            if timeRemaining <= 0 {
                isBreathingIn.toggle()
                if !exercise.animations {
                    animateCircle = true
                }
                
                timeRemaining = isBreathingIn ? exercise.breathingInDuration : exercise.breathingOutDuration
                
                if !isBreathingIn {
                    breathsRemaining -= 1
                    if breathsRemaining <= 0 {
                        timer?.invalidate()
                        isPlaying = false
                    }
                }
            }
                        
            if isBreathingIn {
                scale = 1.0
                opacity = 0.8
            } else {
                scale = 0.3
                opacity = 0.25
            }
        }
    }
    
    func updateBreathing() {
        if isBreathingIn {
            scale = 1.0
            opacity = 0.8
        } else {
            scale = 0.3
            opacity = 0.25
        }
    }
}


struct SliderSheetView: View {
    @EnvironmentObject var exercise: Exercise
    @Environment(\.presentationMode) var presentationMode
    
    @State private var themeColor: Color = .black
    
    var body: some View {
        NavigationView {
            Form {
                VStack(spacing: 20) {
                    Section {
                        HStack {
                            Text("Breathing In:")
                            Spacer()
                            Text("\(exercise.breathingInDuration, specifier: "%.1f") s")
                                .foregroundColor(themeColor)
                        }
                        Slider(value: $exercise.breathingInDuration, in: 1...10, step: 0.1)
                    }
                    
                    HStack {
                        Text("Breathing Out:")
                        Spacer()
                        Text("\(exercise.breathingOutDuration, specifier: "%.1f") s")
                            .foregroundColor(themeColor)
                    }
                    Slider(value: $exercise.breathingOutDuration, in: 1...10, step: 0.1)
                    
                    HStack {
                        Text("Repetitions:")
                        Spacer()
                        Text("\(exercise.repetitions)")
                            .foregroundColor(themeColor)
                    }
                    Slider(value: Binding(get: {
                        Double(exercise.repetitions)
                    }, set: {
                        exercise.repetitions = Int16($0)
                    }), in: 1...20, step: 1)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
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
        newEx.breathingOutDuration = 4.0
        newEx.color = ".black"
        newEx.createdTime = Date()
        newEx.favorite = false
        newEx.repetitions = 5
        newEx.updatedTime = Date()
        newEx.title = "Title \(UUID())"
        
        return BreathingView(exercise: newEx)
            .environment(\.managedObjectContext, viewContext)
    }
}

