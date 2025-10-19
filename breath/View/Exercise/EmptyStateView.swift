//
//  EmptyStateView.swift
//  breath
//
//  Created by Benjamin on 19.10.25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.mind.and.body")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Exercises")
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
        .padding(40)
        //.glassEffect(.regular, in: .rect(cornerRadius: 12))
    }
}

struct EmptyState_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [.cyan.opacity(0.3), .blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            EmptyStateView()
        }
    }
}
