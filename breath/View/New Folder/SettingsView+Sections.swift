//
//  SettingsView+Sections.swift
//  breath
//
//  Created by Benjamin on 20.10.25.
//

import SwiftUI

// MARK: - Sections
extension SettingsView {
    var feedbackSection: some View {
        Section("Feedback & Guidance") {
            Toggle(isOn: $hapticsEnabled) {
                SettingsRowLabel(
                    title: "Haptics",
                    subtitle: "Pulse and impact cues during sessions",
                    systemImage: "waveform.path.ecg"
                )
            }
            .toggleStyle(.switch)
            .sensoryFeedback(.selection, trigger: hapticsEnabled)

            Toggle(isOn: $reduceAnimations) {
                SettingsRowLabel(
                    title: "Reduce Motion",
                    subtitle: "Simplify breathing animations",
                    systemImage: "slowmo"
                )
            }
            .toggleStyle(.switch)
        }
    }

    var appearanceSection: some View {
        Section("Appearance") {
            Toggle(isOn: $usePerExerciseColors) {
                SettingsRowLabel(
                    title: "Color Per Exercise",
                    subtitle: "Respect saved colors when viewing cards",
                    systemImage: "paintpalette"
                )
            }

            ColorPicker(
                "Default Card Color",
                selection: Binding(
                    get: { defaultCardColor.color },
                    set: { color in
                        defaultCardColorHex = DefaultCardColor(color: color).hexString
                    }
                ),
                supportsOpacity: false
            )
            .disabled(usePerExerciseColors)
            .opacity(usePerExerciseColors ? 0.4 : 1)

            shapeSelector
            shapePreview
        }
    }

    var aboutSection: some View {
        Section("About") {
            LabeledContent {
                Text(appVersion)
                    .foregroundStyle(.secondary)
            } label: {
                Label("Version", systemImage: "info")
            }

            if let supportURL = URL(string: "mailto:hello@breath.app") {
                Link(destination: supportURL) {
                    Label("Email Support", systemImage: "envelope")
                }
            }
        }
    }
}

// MARK: - Subviews
extension SettingsView {
    var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: "wind")
                .font(.system(size: 30, weight: .semibold))
                .frame(width: 58, height: 58)
                .background(
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.18))
                )
                .foregroundStyle(.primary)

            Text("Tune your practice")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Adjust guidance, audio, and visuals to match the breathing routine you prefer.")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

    }
}

// MARK: - Appearance Helpers
extension SettingsView {
    var shapeSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Breathing indicator")
                .font(.headline)
            Text("Choose the shape for the animated focus point.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker("Breathing indicator", selection: $breathingShapeRawValue) {
                ForEach(BreathingShape.allCases) { shape in
                    Text(shape.displayName)
                        .tag(shape.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 4)
    }

    var shapePreview: some View {
        let accent = usePerExerciseColors ? Color.accentColor : defaultCardColor.color
        let shape = indicatorShape(for: breathingShape)

        return HStack(spacing: 18) {
            shape
                .fill(accent.gradient)
                .frame(width: 72, height: 72)
                .overlay(
                    shape
                        .stroke(accent.opacity(0.35), lineWidth: 2)
                )
                .shadow(color: accent.opacity(0.25), radius: 8, x: 0, y: 6)

            VStack(alignment: .leading, spacing: 6) {
                Text("Preview")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("\(breathingShape.displayName) indicator uses \(usePerExerciseColors ? "per-exercise tint" : "the default color").")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(accent.opacity(0.12))
                .glassEffect(
                    .regular
                        .tint(accent.opacity(0.25))
                        .interactive(),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
        )
    }

    func indicatorShape(for shape: BreathingShape) -> AnyShape {
        switch shape {
        case .circle:
            return AnyShape(Circle())
        case .square:
            return AnyShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        case .triangle:
            return AnyShape(TriangleShape())
        }
    }

    var breathingShape: BreathingShape {
        BreathingShape(rawValue: breathingShapeRawValue) ?? .circle
    }

    var defaultCardColor: DefaultCardColor {
        get { DefaultCardColor(hex: defaultCardColorHex) }
        set { defaultCardColorHex = newValue.hexString }
    }

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return version
    }
}

#Preview {
    SettingsView()
}
