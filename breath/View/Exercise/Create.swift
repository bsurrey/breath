//
//  Create.swift
//  breath
//
//  Created by Benjamin on 19.10.25.
//

import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage(SettingsKey.usePerExerciseColors) private var usePerExerciseColors = true
    @AppStorage(SettingsKey.defaultCardColor) private var defaultCardColorHex = DefaultCardColor.default.hexString
    
    @State private var breathingInDuration: Double = 4.0
    @State private var breathingOutDuration: Double = 7.0
    @State private var repetitions: Int = 11
    @State private var title: String = ""
    @State private var bgColor = Color.blue
    @State private var activateAnimations: Bool = true

    init() {
        let storedHex = UserDefaults.standard.string(forKey: SettingsKey.defaultCardColor) ?? DefaultCardColor.default.hexString
        _bgColor = State(initialValue: DefaultCardColor(hex: storedHex).color)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section {
                        TextField("Exercise Name", text: $title)
                    }
                    
                    Section {
                        HStack {
                            Text("Breathing In:")
                            Spacer()
                            Text("\(breathingInDuration, specifier: "%.f") s")
                        }
                        
                        Slider(value: $breathingInDuration, in: 1...10, step: 0.1)
                        
                        HStack {
                            Text("Breathing Out:")
                            Spacer()
                            Text("\(breathingOutDuration, specifier: "%.f") s")
                        }
                        Slider(value: $breathingOutDuration, in: 1...10, step: 0.1)
                        
                        HStack {
                            Text("Repetitions:")
                            Spacer()
                            Text("\(repetitions) x")
                        }
                        Slider(value: Binding(get: {
                            Double(repetitions)
                        }, set: {
                            repetitions = Int($0)
                        }), in: 1...20, step: 1)
                    }
                    .tint(bgColor)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        ColorPicker("Color", selection: $bgColor, supportsOpacity: false)
                            .disabled(!usePerExerciseColors)
                            .opacity(usePerExerciseColors ? 1 : 0.4)
                    }
                    
                    Section {
                        Toggle(isOn: $activateAnimations) {
                            Text("Activate Animations")
                        }
                        Toggle(isOn: $activateAnimations) {
                            Text("Start instantly")
                        }
                    }
                    .tint(bgColor)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        addItem()
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addItem() {
        let clampedRepetitions = max(repetitions, 1)
        let clampedIn = max(breathingInDuration, 1)
        let clampedOut = max(breathingOutDuration, 1)

        let effectiveColor: Color = usePerExerciseColors ? bgColor : DefaultCardColor(hex: defaultCardColorHex).color
        let rgb = effectiveColor.toRGB()
        let defaultColor = DefaultCardColor(color: effectiveColor)
        let exercise = Exercise(
            title: title.isEmpty ? "Exercise" : title,
            breathingInDuration: clampedIn,
            breathingOutDuration: clampedOut,
            repetitions: clampedRepetitions,
            animations: activateAnimations,
            createdTime: .now,
            updatedTime: .now,
            red: rgb.red,
            green: rgb.green,
            blue: rgb.blue,
            color: defaultColor.hexString
        )

        modelContext.insert(exercise)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            assertionFailure("Failed to save exercise: \(error)")
        }
    }
}
