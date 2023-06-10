//
//  CardPreviewView.swift
//  breath
//
//  Created by Benjamin Surrey on 07.05.23.
//

import SwiftUI

struct CardPreviewView: View {
    @State private var breathingInDuration: Double = 4.0
    @State private var breathingOutDuration: Double = 7.0
    @State private var repetitions: Int16 = 11
    @State private var title: String = ""
    @State private var bgColor = Color.blue
    @State private var activateAnimations: Bool = true
    
    var body: some View {
        VStack(spacing: 10) {
            VStack {
                HStack {
                    Text(title )
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .bold()
                    
                    Spacer()
                    
                    Label {
                        Text(" \((2.0), specifier: "%.f") min")
                    } icon: {
                        Image(systemName: "clock")
                    }
                }.padding(.bottom)
                
                
                Spacer()
                
                HStack {
                    Label {
                        Text("\(5.0, specifier: "%.f") s in")
                    } icon: {
                        Image(systemName: "wind.circle")
                    }
                    
                    Spacer()
                    
                    Label {
                        Text("\(7.6, specifier: "%.f") s out")
                    } icon: {
                        Image(systemName: "wind.circle")
                    }
                    
                    Spacer()
                    
                    Label {
                        Text("\(9.0, specifier: "%.f") x")
                    } icon: {
                        Image(systemName: "repeat")
                    }
                }
            }
        }
        .foregroundColor(.white)
        .padding()
        .background(bgColor)
    }
}

struct CardPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        CardPreviewView()
    }
}
