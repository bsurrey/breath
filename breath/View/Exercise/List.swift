//
//  List.swift
//  breath
//
//  Created by Benjamin on 19.10.25.
//

import SwiftUI

struct ListView: View {
    public var exercises: FetchedResults<Exercise>
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(exercises) { exercise in
                    CardView(exercise: exercise)
                        .swipeActions(allowsFullSwipe: false) {
                            Button {
                                print("Muting conversation")
                            } label: {
                                Label("Mute", systemImage: "bell.slash.fill")
                            }
                            .tint(.indigo)
                            
                            Button(role: .destructive) {
                                print("Deleting conversation")
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                        }
                    
                }
            }
        }
    }
}
