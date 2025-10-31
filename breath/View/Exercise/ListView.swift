//
//  ListView.swift
//  breath
//
//  Created by Benjamin on 19.10.25.
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var modelContext
    var exercises: [Exercise]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(exercises) { exercise in
                    CardView(exercise: exercise)
                        .swipeActions(allowsFullSwipe: false) {
                            Button {
                                exercise.animations.toggle()
                                try? modelContext.save()
                            } label: {
                                Label("Mute", systemImage: "bell.slash.fill")
                            }
                            .tint(.indigo)

                            Button(role: .destructive) {
                                withAnimation {
                                    modelContext.delete(exercise)
                                    try? modelContext.save()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    do {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Exercise.self, configurations: configuration)
        let context = container.mainContext

        for index in 0..<4 {
            let tint = Color(hue: Double(index) / 4.0, saturation: 0.6, brightness: 0.85)
            let rgb = tint.toRGB()
            let exercise = Exercise(
                title: "Sample \(index + 1)",
                breathingInDuration: 4 + Double(index),
                breathingOutDuration: 6 + Double(index),
                repetitions: 6 + index,
                animations: index.isMultiple(of: 2),
                red: rgb.red,
                green: rgb.green,
                blue: rgb.blue
            )
            context.insert(exercise)
        }

        try context.save()

        let descriptor = FetchDescriptor<Exercise>(sortBy: [SortDescriptor(\.createdTime)])
        let sampleExercises = try context.fetch(descriptor)

        return ListView(exercises: sampleExercises)
            .modelContainer(container)
    } catch {
        return Text("Preview failed: \(error.localizedDescription)")
    }
}
