//
//  ExerciseSettings.swift
//  breath
//
//  Created by Benjamin Surrey on 01.07.23.
//

import SwiftUI


struct ExerciseSettingsView: View {
    @EnvironmentObject var exercise: Exercise
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var themeColor: Color = .black
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(spacing: 20) {
                    Section {
                        HStack {
                            Text("Breathing In:")
                            Spacer()
                            Text("\(exercise.breathingInDuration, specifier: "%.f") s")
                                .foregroundColor(themeColor)
                        }
                        Slider(value: $exercise.breathingInDuration, in: 1...10, step: 1)
                            .onChange(of: exercise.breathingInDuration) { _ in
                                saveExercise()
                            }
                    }
                    
                    HStack {
                        Text("Breathing Out:")
                        Spacer()
                        Text("\(exercise.breathingOutDuration, specifier: "%.f") s")
                            .foregroundColor(themeColor)
                    }
                    Slider(value: $exercise.breathingOutDuration, in: 1...10, step: 1)
                        .onChange(of: exercise.breathingOutDuration) { _ in
                            saveExercise()
                        }
                    
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
                        .onChange(of: exercise.repetitions) { _ in
                            saveExercise()
                        }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func saveExercise() {
        do {
            try managedObjectContext.save()
        } catch {
            // Handle the error appropriately in a production app
            print("Failed to save exercise: \(error)")
        }
    }
}
