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
    @AppStorage(SettingsKey.usePerExerciseColors) private var usePerExerciseColors = true
    @AppStorage(SettingsKey.defaultCardColor) private var defaultCardColorHex = DefaultCardColor.default.hexString
    var exercises: [Exercise]

    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink {
                    BreathingView(exercise: exercise)
                } label: {
                    ExerciseListRow(
                        exercise: exercise,
                        themeColor: themeColor(for: exercise)
                    )
                }
                .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
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
        .listStyle(.plain)
        .applyListRowSpacing(12)
        .scrollContentBackground(.hidden)
    }

    private func themeColor(for exercise: Exercise) -> Color {
        if usePerExerciseColors {
            if !exercise.color.isEmpty {
                return DefaultCardColor(hex: exercise.color).color
            }
            return Color.fromRGB(red: exercise.red, green: exercise.green, blue: exercise.blue)
        }

        return DefaultCardColor(hex: defaultCardColorHex).color
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

private struct ExerciseListRow: View {
    let exercise: Exercise
    let themeColor: Color

    private var approximateMinutes: Int {
        let totalSeconds = (exercise.breathingInDuration + exercise.breathingOutDuration) * Double(exercise.repetitions)
        return Int(ceil(totalSeconds / 60.0))
    }

    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                themeColor,
                themeColor.lighter(by: 0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(exercise.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Label {
                    Text("~ \(approximateMinutes) min")
                } icon: {
                    Image(systemName: "clock")
                }
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.85))
            }

            HStack(spacing: 12) {
                statLabel(
                    icon: "arrow.down.circle",
                    text: formattedSeconds(exercise.breathingInDuration, suffix: "s in")
                )
                Spacer(minLength: 8)
                statLabel(
                    icon: "arrow.up.circle",
                    text: formattedSeconds(exercise.breathingOutDuration, suffix: "s out")
                )
                Spacer(minLength: 8)
                statLabel(
                    icon: "repeat",
                    text: "\(exercise.repetitions) x"
                )
            }
            .font(.subheadline)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(gradient)
                .shadow(color: themeColor.opacity(0.18), radius: 10, y: 6)
        )
        .foregroundStyle(.white)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func statLabel(icon: String, text: String) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: icon)
        }
        .foregroundStyle(Color.white.opacity(0.92))
        .lineLimit(1)
        .minimumScaleFactor(0.85)
    }

    private func formattedSeconds(_ value: Double, suffix: String) -> String {
        let seconds = Int((value).rounded())
        return "\(seconds) \(suffix)"
    }
}

private extension View {
    @ViewBuilder
    func applyListRowSpacing(_ spacing: CGFloat) -> some View {
        if #available(iOS 17.0, *) {
            listRowSpacing(spacing)
        } else {
            self
        }
    }
}
