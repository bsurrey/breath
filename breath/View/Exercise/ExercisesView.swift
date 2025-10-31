//
//  ExercisesView.swift
//  breath
//
//  Created by Benjamin Surrey on 05.05.23.
//

import SwiftUI
import SwiftData

struct ExercisesView: View {
    @Query(
        sort: [SortDescriptor(\Exercise.createdTime, order: .forward)],
        animation: .default
    )
    private var exercises: [Exercise]
    
    var body: some View {
        if exercises.isEmpty {
            EmptyStateView()
        } else {
            ListView(exercises: exercises)
        }
    }
}

@MainActor
private func makeExercisesPreviewContainer() -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: configuration)
    let context = container.mainContext

    if (try? context.fetch(FetchDescriptor<Exercise>()))?.isEmpty ?? true {
        for index in 0..<3 {
            let color = Color(hue: Double(index) / 3.0, saturation: 0.65, brightness: 0.85)
            let rgb = color.toRGB()
            let exercise = Exercise(
                title: "Preview Session \(index + 1)",
                breathingInDuration: 4 + Double(index),
                breathingOutDuration: 6 + Double(index),
                repetitions: 5 + index,
                animations: true,
                red: rgb.red,
                green: rgb.green,
                blue: rgb.blue
            )
            context.insert(exercise)
        }
        try! context.save()
    }

    return container
}

#Preview("Exercises list") {
    ExercisesView()
        .modelContainer(makeExercisesPreviewContainer())
}
