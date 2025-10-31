//
//  MainView.swift
//  breath
//
//  Created by Benjamin Surrey on 06.05.23.
//  Updated for iOS 26
//

import SwiftUI

struct MainView: View {
    @State private var showingAddItemView = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            ExercisesView()
                .navigationTitle("Mindful Exercises")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarLeading) {
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            showingAddItemView = true
                        } label: {
                            Label("New Exercise", systemImage: "plus")
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.accentColor)
                    }
                }
                .sheet(isPresented: $showingAddItemView) {
                    AddItemView()
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
        }
    }
}



#Preview {
    MainView()
}
