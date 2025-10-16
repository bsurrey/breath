//
//  MainView.swift
//  breath
//
//  Created by Benjamin Surrey on 06.05.23.
//

import SwiftUI

private enum MainTab: Hashable {
    case exercises
    case settings
}

struct MainView: View {
    @State private var selection: MainTab = .exercises

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                ExercisesView()
                    .tabItem {
                        Label("Breathing", systemImage: "wind")
                    }
                    .tag(MainTab.exercises)
                    .accessibilityLabel("Breathing Exercises")
                    .toolbarTitleDisplayMode(.large)
                    .navigationTitle("Breathing Exercises")

                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(MainTab.settings)
                    .accessibilityLabel("Settings")
                    .toolbarTitleDisplayMode(.large)
                    .navigationTitle("Settings")
            }
            .tint(.accentColor)
        }
    }
}

private struct SettingsView: View {
    var body: some View {
        List {
            Section("General") {
                Toggle(isOn: .constant(true)) {
                    Label("Haptics", systemImage: "waveform")
                }
                Toggle(isOn: .constant(false)) {
                    Label("Sound", systemImage: "speaker.wave.2")
                }
            }

            Section("About") {
                HStack {
                    Label("Version", systemImage: "info.circle")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
