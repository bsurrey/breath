//
//  breathApp.swift
//  breath
//
//  Created by Benjamin Surrey on 05.05.23.
//

import SwiftUI

@main
struct breathApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
