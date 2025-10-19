//
//  Create.swift
//  breath
//
//  Created by Benjamin on 19.10.25.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var breathingInDuration: Double = 4.0
    @State private var breathingOutDuration: Double = 7.0
    @State private var repetitions: Int16 = 11
    @State private var title: String = ""
    @State private var bgColor = Color.blue
    @State private var activateAnimations: Bool = true
    
    var body: some View {
        NavigationView {
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
                            repetitions = Int16($0)
                        }), in: 1...20, step: 1)
                    }
                    .tint(bgColor)
                    .listRowSeparator(.hidden)
                    
                    Section {
                        ColorPicker("Color", selection: $bgColor, supportsOpacity: false)
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
            .navigationBarTitle("New Exercises", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // Save new item and dismiss the sheet
                        addItem()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newExercise = Exercise(context: viewContext)
            newExercise.title = title.isEmpty ? "Exercise" : title
            newExercise.animations = activateAnimations
            newExercise.repetitions = repetitions <= 0 ? 1 : repetitions
            newExercise.breathingInDuration = breathingInDuration <= 0 ? 1 :breathingInDuration
            newExercise.breathingOutDuration = breathingOutDuration <= 0 ? 1 : breathingOutDuration
            newExercise.updatedTime = Date()
            newExercise.createdTime = Date()
            newExercise.uuid = UUID()
            
            let rgb = bgColor.toRGB()
            newExercise.red = rgb.red
            newExercise.blue = rgb.blue
            newExercise.green = rgb.green
            
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
