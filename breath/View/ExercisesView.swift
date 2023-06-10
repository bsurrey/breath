//
//  ExercisesView.swift
//  breath
//
//  Created by Benjamin Surrey on 05.05.23.
//

import SwiftUI

struct ExercisesView: View {
    @State private var showingAddItemView = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.createdTime, ascending: true)],
        animation: .default)
    private var exercises: FetchedResults<Exercise>
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(exercises) { exercise in
                        CardView(exercise: exercise)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Mindfull Exercises")
            .toolbar {
                ToolbarItem {
                    Button(action: { showingAddItemView.toggle() }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItemView) {
                AddItemView()
            }
        }
    }
}

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

struct CardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise
    
    var body: some View {
        NavigationLink(destination: BreathingView(exercise: exercise)) {
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    HStack {
                        Text(exercise.title ?? "Exercise")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .bold()
                        
                        Spacer()
                        
                        Label {
                            Text("~ \(ceil((exercise.breathingInDuration + exercise.breathingOutDuration) * Double(exercise.repetitions) / 60), specifier: "%.f") min")
                        } icon: {
                            Image(systemName: "clock")
                        }
                    }.padding(.bottom)
                    
                    
                    Spacer()
                    
                    HStack {
                        Label {
                            Text("\(exercise.breathingInDuration, specifier: "%.f") s in")
                        } icon: {
                            Image(systemName: "wind.circle")
                        }
                        
                        Spacer()
                        
                        Label {
                            Text("\(exercise.breathingOutDuration, specifier: "%.f") s out")
                        } icon: {
                            Image(systemName: "wind.circle")
                        }
                        
                        Spacer()
                        
                        Label {
                            Text("\(exercise.repetitions) x")
                        } icon: {
                            Image(systemName: "repeat")
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
