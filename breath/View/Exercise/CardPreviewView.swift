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
    @State private var repetitions: Int = 11
    @State private var title: String = ""
    @State private var bgColor = Color.blue
    @State private var activateAnimations: Bool = true
    
    private var accentColor: Color {
        bgColor
    }
    
    private var accentHighlight: Color {
        accentColor.lighter(by: 0.5)
    }

    private var textColor: Color {
        accentHighlight.isVisuallyLight ? .black : .white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(title.isEmpty ? "Preview" : title)
                    .font(.headline)
                    .bold()
                    .lineLimit(1)
                    .foregroundColor(textColor)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                    Text("~ 2 min")
                }
                .font(.subheadline)
                .foregroundStyle(textColor.opacity(0.65))
            }
            
            Divider().opacity(0.15)
            
            HStack {
                Label("5 s in", systemImage: "wind.circle")
                Spacer()
                Label("8 s out", systemImage: "wind.circle")
                Spacer()
                Label("9 x", systemImage: "repeat")
            }
            .font(.subheadline)
            .foregroundStyle(textColor.opacity(0.75))
            .symbolRenderingMode(.monochrome)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(textColor)
        .background(cardBackground)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(accentHighlight.opacity(0.16))
            .glassEffect(
                .regular
                    .tint(accentColor.opacity(0.35))
                    .interactive(),
                in: RoundedRectangle(cornerRadius: 24, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(accentHighlight.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: accentColor.opacity(0.24), radius: 12, x: 0, y: 10)
    }
}

struct CardPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        CardPreviewView()
    }
}
