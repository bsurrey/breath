//
//  Card.swift
//  breath
//
//  Created by Benjamin on 19.10.25.
//

import SwiftUI

struct CardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var exercise: Exercise
    
    var body: some View {
        NavigationLink(destination: BreathingView(exercise: exercise)) {
            VStack(alignment: .leading, spacing: 10) {
                VStack {
                    HStack {
                        Text(exercise.title ?? "Exercise")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .bold()
                        
                        Spacer()
                        
                        Label {
                            Text("~ \(ceil((exercise.breathingInDuration + exercise.breathingOutDuration) * Double(exercise.repetitions) / 60), specifier: "%.f") min")
                        } icon: {
                            Image(systemName: "clock")
                        }
                    }.padding(.bottom)
                    
                    
                    Spacer()
                    
                    HStack {
                        Label {
                            Text("\(exercise.breathingInDuration, specifier: "%.f") s in")
                        } icon: {
                            Image(systemName: "wind.circle")
                        }
                        
                        Spacer()
                        
                        Label {
                            Text("\(exercise.breathingOutDuration, specifier: "%.f") s out")
                        } icon: {
                            Image(systemName: "wind.circle")
                        }
                        
                        Spacer()
                        
                        Label {
                            Text("\(exercise.repetitions) x")
                        } icon: {
                            Image(systemName: "repeat")
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.fromRGB(red: exercise.red, green: exercise.green, blue: exercise.blue))
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
        }
    }
}
