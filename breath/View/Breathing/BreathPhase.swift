//
//  BreathPhase.swift
//  breath
//

import SwiftUI

enum BreathPhase: Equatable {
    case ready, inhale, hold, exhale

    var title: String {
        switch self {
        case .ready: return "Ready"
        case .inhale: return "Breathe In"
        case .hold: return "Hold"
        case .exhale: return "Breathe Out"
        }
    }

    var subtitle: String {
        switch self {
        case .ready: return ""
        case .inhale: return "Fill your lungs"
        case .hold: return "Keep it steady"
        case .exhale: return "Release slowly"
        }
    }
}
