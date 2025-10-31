//
//  breathApp.swift
//  breath
//
//  Created by Benjamin Surrey on 05.05.23.
//

import SwiftUI
import SwiftData

@main
struct breathApp: App {
    @MainActor
    static let sharedModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Exercise.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(Self.sharedModelContainer)
    }
}
