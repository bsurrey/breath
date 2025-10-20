//
//  SettingsRowLabel.swift
//  breath
//
//  Created by Benjamin on 20.10.25.
//

import SwiftUI

struct SettingsRowLabel: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: systemImage)
                .imageScale(.large)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.tint)
        }
    }
}

#Preview {
    SettingsRowLabel(title: "test", subtitle: "idk", systemImage: "eyedropper")
}
