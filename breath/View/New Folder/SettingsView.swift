//
//  SettingsView.swift
//  breath
//
//  Created by Benjamin on 20.10.25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(SettingsKey.hapticsEnabled) var hapticsEnabled = true
    @AppStorage(SettingsKey.soundEnabled) var soundEnabled = false
    @AppStorage(SettingsKey.reduceAnimations) var reduceAnimations = false
    @AppStorage(SettingsKey.usePerExerciseColors) var usePerExerciseColors = true
    @AppStorage(SettingsKey.defaultCardColor) var defaultCardColorHex = DefaultCardColor.default.hexString
    @AppStorage(SettingsKey.breathingShape) var breathingShapeRawValue = BreathingShape.circle.rawValue

    @State var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    headerCard
                }

                feedbackSection
                appearanceSection
                aboutSection
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
