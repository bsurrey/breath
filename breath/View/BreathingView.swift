//
//  BreathingView.swift
//  breath
//
//  Created by Benjamin Surrey on 06.05.23.
//

import SwiftUI
import AudioToolbox

struct BreathingView: View {
    // Circle
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    @State private var initialScale: Float = 0.5
    @State private var initialOpacity: Float = 1.0
    
    // States
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var isBreathingIn = true
    @State private var isHolding = false
    
    // Timer
    @State private var timer: ResumableTimer?
    @State private var remainingRounds: Int = 5
    @State private var remainingTimeForThisRound: Double = 0
    @State private var currentRound: Int = 1
    @State private var holdingTime: Int = 4
    
    // Data
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise
    
    // Ripples
    @State private var rippleOpacities: [Double] = [0.6, 0.8, 1.0]
    @State private var rippleScales: [CGFloat] = [0.5, 0.5, 0.5]
    
    // Settings
    @State private var showSheet = false
    
    // Design
    @State private var animateCircle = true
    @State private var themeColor: Color = .black
    
    @State var show = false
    
    var body: some View {
        ScrollView {
            HStack {
                if isRunning {
                    if isBreathingIn {
                        Text("Breath in")
                            .font(.title)
                            .fontWeight(.medium)
                    } else {
                        Text("Breath out")
                            .font(.title)
                            .fontWeight(.medium)
                    }
                }
            }
            //.frame(width: .infinity, height: 100)
            
            ZStack {
                if !isRunning {
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(themeColor, lineWidth: 5)
                            .scaleEffect(rippleScales[index])
                            .opacity(rippleOpacities[index])
                            .animation(Animation.easeOut(duration: 5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 1))
                            .onAppear {
                                DispatchQueue.main.async {
                                    self.show = true
                                }
                                rippleScales[index] = 1.0
                                rippleOpacities[index] = 0.0
                            }
                            .frame(width: 400.0, height: 200)

                    }
                }
                
                Circle()
                    .fill(themeColor)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .animation(exercise.animations ? .linear : .none)
                
                Text(String(format: "%.f", remainingTimeForThisRound / 10))
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
            }
            //.frame(width: .infinity, height: 400, alignment: .center)
            //.background(.red)
            
            Text("\(remainingRounds) Rounds")
                .font(.title3)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    stop()
                }) {
                    Image(systemName: "stop.circle")
                        .font(.system(size: 32))
                    //.foregroundColor(themeColor)
                }
                
                Button(action: {
                    if !isRunning && !isPaused {
                        startExercise()
                    } else {
                        if isRunning {
                            pauseTimer()
                        } else if isPaused {
                            resume()
                        }
                    }
                }) {
                    if isRunning {
                        Image(systemName: "pause.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(themeColor)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(themeColor)
                    }
                }
                .padding(.all)
                
                Button(action: {
                    addRound()
                }) {
                    Image(systemName: "goforward.plus")
                        .font(.system(size: 32))
                    //.foregroundColor(themeColor)
                }
                
                Spacer()
                
            }
            .padding(.bottom)
        }
        .navigationTitle(exercise.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    showSheet.toggle()
                }) {
                    Label {
                        Text("Settings")
                    } icon: {
                        Image(systemName: "info.circle")
                    }
                }
                .foregroundColor(themeColor)
            }
        }
        .sheet(isPresented: $showSheet) {
            ExerciseSettingsView()
                .environmentObject(exercise)
        }
        .onAppear {
            themeColor = Color.fromRGB(red: exercise.red, green: exercise.green, blue: exercise.blue)
            
            
            initialize()
            
            timer = ResumableTimer(interval: 0.1) {
                run()
            }
        }
        .onDisappear {
            destuction()
        }
    }
    
    // Code to execute when the timer fires.
    func run() {
        remainingTimeForThisRound -= 1
        
        if remainingTimeForThisRound <= 0 {
            isBreathingIn = !isBreathingIn
            
            if isBreathingIn {
                remainingTimeForThisRound = exercise.breathingInDuration * 10
            } else {
                remainingTimeForThisRound = exercise.breathingOutDuration * 10
            }
            
            remainingRounds -= 1
        }
        
        if remainingRounds == 0 {
            stop()
        }
        
        if isBreathingIn {
            scale = getScale(remainingTime: remainingTimeForThisRound, totalTime: exercise.breathingInDuration * 10, isBreathingIn: isBreathingIn)
        } else {
            scale = getScale(remainingTime: remainingTimeForThisRound, totalTime: exercise.breathingOutDuration * 10, isBreathingIn: isBreathingIn)
        }
        
        print(remainingTimeForThisRound)
    }
    
    func getScale(remainingTime: Double, totalTime: Double, isBreathingIn: Bool) -> Double {
        var remaining = remainingTime - 1
        
        if isBreathingIn {
            return ((0.4 / totalTime) * (totalTime - remaining)) + 0.5
        } else {
            return ((0.4 / totalTime) * remaining) + 0.5
        }
        //var calc = ((0.5 / totalTime) * (totalTime - remainingTime)) + 0.5
        // var calc = (1.00 / totalTime) * (totalTime - remainingTime)
        
        
    }
    
    func initialize() {
        remainingRounds = Int(exercise.repetitions)
        remainingTimeForThisRound = exercise.breathingInDuration  * 10
        isPaused = false
        isRunning = false
        isBreathingIn = true
        
        scale = 0.5
        opacity = 1.0
        initialScale = 0.5
        initialOpacity = 1.0
    }
    
    func startExercise() {
        isRunning = true
        // timer?.start()
        
        if isBreathingIn {
            remainingTimeForThisRound = exercise.breathingInDuration * 10
        } else {
            remainingTimeForThisRound = exercise.breathingOutDuration * 10
        }
        
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
        // timer?.resume() buggy
        isRunning = true
        isPaused = false
    }
    
    func destuction() {
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

