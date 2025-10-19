//
//  SettingsView.swift
//  breath
//
//  Created by Benjamin on 20.10.25.
//

import SwiftUI

enum SettingsKey {
    static let hapticsEnabled = "settings.hapticsEnabled"
    static let soundEnabled = "settings.soundEnabled"
    static let reduceAnimations = "settings.reduceAnimations"
    static let usePerExerciseColors = "settings.usePerExerciseColors"
    static let accentPalette = "settings.accentPalette"
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(SettingsKey.hapticsEnabled) private var hapticsEnabled = true
    @AppStorage(SettingsKey.soundEnabled) private var soundEnabled = false
    @AppStorage(SettingsKey.reduceAnimations) private var reduceAnimations = false
    @AppStorage(SettingsKey.usePerExerciseColors) private var usePerExerciseColors = true
    @AppStorage(SettingsKey.accentPalette) private var accentPaletteRawValue = AccentPalette.calmSky.rawValue

    @State private var showResetConfirmation = false

    private var accentPalette: AccentPalette {
        AccentPalette(rawValue: accentPaletteRawValue) ?? .calmSky
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return version
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    headerCard
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

                Section("Feedback & Guidance") {
                    Toggle(isOn: $hapticsEnabled) {
                        SettingsRowLabel(
                            title: "Haptics",
                            subtitle: "Pulse and impact cues during sessions",
                            systemImage: "waveform.path.ecg"
                        )
                    }
                    .toggleStyle(.switch)
                    .tint(.accentColor)
                    .sensoryFeedback(.selection, trigger: hapticsEnabled)

                    Toggle(isOn: $soundEnabled) {
                        SettingsRowLabel(
                            title: "Sound",
                            subtitle: "Tone markers for inhale and exhale",
                            systemImage: "speaker.wave.2"
                        )
                    }
                    .toggleStyle(.switch)
                    .tint(.accentColor)

                    Toggle(isOn: $reduceAnimations) {
                        SettingsRowLabel(
                            title: "Reduce Motion",
                            subtitle: "Simplify breathing animations",
                            systemImage: "slowmo"
                        )
                    }
                    .toggleStyle(.switch)
                    .tint(.accentColor)
                }

                Section("Appearance") {
                    Picker("Card Palette", selection: $accentPaletteRawValue) {
                        ForEach(AccentPalette.allCases) { palette in
                            paletteRow(for: palette)
                                .tag(palette.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle(isOn: $usePerExerciseColors) {
                        SettingsRowLabel(
                            title: "Color Per Exercise",
                            subtitle: "Respect saved colors when viewing cards",
                            systemImage: "paintpalette"
                        )
                    }
                    .toggleStyle(.switch)
                    .tint(.accentColor)
                }

                Section("About") {
                    LabeledContent {
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    } label: {
                        Label("Version", systemImage: "info.circle")
                    }

                    if let supportURL = URL(string: "mailto:hello@breath.app") {
                        Link(destination: supportURL) {
                            Label("Email Support", systemImage: "envelope")
                        }
                    }

                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Reset Settings", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .formStyle(.grouped)
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.glass)
                    .tint(.accentColor)
                }
            }
            .confirmationDialog(
                "Reset Settings",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive, action: resetPreferences)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Restore haptics, sound, and appearance preferences to their defaults.")
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Subviews
private extension SettingsView {
    var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "wind")
                .font(.system(size: 30, weight: .semibold))
                .frame(width: 58, height: 58)
                .background(
                    Circle()
                        .fill(Color.accentColor.opacity(0.18))
                        .overlay(
                            Circle()
                                .stroke(Color.accentColor.opacity(0.35), lineWidth: 1)
                        )
                )
                .foregroundStyle(.primary)

            Text("Tune your practice")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Adjust guidance, audio, and visuals to match the breathing routine you prefer.")
                .font(.callout)
                .foregroundStyle(.secondary)

            palettePreview
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.accentColor.opacity(0.16))
                .glassEffect(
                    .regular
                        .tint(Color.accentColor.opacity(0.35))
                        .interactive(),
                    in: RoundedRectangle(cornerRadius: 28, style: .continuous)
                )
        )
    }

    var palettePreview: some View {
        HStack(spacing: 12) {
            Text("Selected palette")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                ForEach(Array(accentPalette.previewColors.enumerated()), id: \.offset) { _, color in
                    Capsule()
                        .fill(color)
                        .frame(width: 18, height: 6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.08))
            )
        }
    }

    func paletteRow(for palette: AccentPalette) -> some View {
        HStack(spacing: 12) {
            palette.swatch
            VStack(alignment: .leading, spacing: 2) {
                Text(palette.displayName)
                Text(palette.tagline)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    func resetPreferences() {
        hapticsEnabled = true
        soundEnabled = false
        reduceAnimations = false
        usePerExerciseColors = true
        accentPaletteRawValue = AccentPalette.calmSky.rawValue
    }
}

// MARK: - Helpers
private struct SettingsRowLabel: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.primary)
        }
    }
}

private enum AccentPalette: String, CaseIterable, Identifiable {
    case calmSky
    case sunsetGlow
    case forestBreeze
    case midnight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .calmSky: return "Calm Sky"
        case .sunsetGlow: return "Sunset Glow"
        case .forestBreeze: return "Forest Breeze"
        case .midnight: return "Midnight"
        }
    }

    var tagline: String {
        switch self {
        case .calmSky: return "Bright blues for focus"
        case .sunsetGlow: return "Warm oranges to unwind"
        case .forestBreeze: return "Grounding greens for balance"
        case .midnight: return "Deep contrast for night sessions"
        }
    }

    var previewColors: [Color] {
        switch self {
        case .calmSky:
            return [
                Color(red: 0.36, green: 0.67, blue: 0.99),
                Color(red: 0.14, green: 0.43, blue: 0.94),
                Color(red: 0.08, green: 0.25, blue: 0.56)
            ]
        case .sunsetGlow:
            return [
                Color(red: 1.00, green: 0.58, blue: 0.39),
                Color(red: 0.99, green: 0.34, blue: 0.34),
                Color(red: 0.75, green: 0.25, blue: 0.35)
            ]
        case .forestBreeze:
            return [
                Color(red: 0.57, green: 0.75, blue: 0.42),
                Color(red: 0.28, green: 0.52, blue: 0.34),
                Color(red: 0.16, green: 0.31, blue: 0.23)
            ]
        case .midnight:
            return [
                Color(red: 0.35, green: 0.38, blue: 0.53),
                Color(red: 0.19, green: 0.21, blue: 0.34),
                Color(red: 0.08, green: 0.10, blue: 0.22)
            ]
        }
    }

    var swatch: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(
                LinearGradient(
                    colors: previewColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 44, height: 28)
    }
}

#Preview {
    SettingsView()
}
