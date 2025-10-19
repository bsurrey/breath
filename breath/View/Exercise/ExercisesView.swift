//
//  ExercisesView.swift
//  breath
//
//  Created by Benjamin Surrey on 05.05.23.
//

import SwiftUI

struct ExercisesView: View {
    @State private var showingAddItemView = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.createdTime, ascending: true)],
        animation: .default)
    private var exercises: FetchedResults<Exercise>
    
    var body: some View {
        if exercises.isEmpty {
            EmptyStateView()
        } else {
            ListView(exercises: exercises)
        }
    }
}


struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        ExercisesView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
        ExercisesView()
    }
}
