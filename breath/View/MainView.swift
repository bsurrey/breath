//
//  MainView.swift
//  breath
//
//  Created by Benjamin Surrey on 06.05.23.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
                ExercisesView()
                    .tabItem {
                        Label("Breathing Exercises", systemImage: "list.bullet")
                    }.tag(1)
                
                Text("Tab Content 2")
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }.tag(3)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
