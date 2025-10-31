//
//  SettingsKeys.swift
//  breath
//
//  Created by Benjamin on 20.10.25.
//

import SwiftUI

enum SettingsKey {
    static let hapticsEnabled = "settings.hapticsEnabled"
    static let soundEnabled = "settings.soundEnabled"
    static let reduceAnimations = "settings.reduceAnimations"
    static let usePerExerciseColors = "settings.usePerExerciseColors"
    static let defaultCardColor = "settings.defaultCardColor"
    static let breathingShape = "settings.breathingShape"
}

enum BreathingShape: String, CaseIterable, Identifiable {
    case circle
    case square
    case triangle

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .circle: return "Circle"
        case .square: return "Square"
        case .triangle: return "Triangle"
        }
    }
}

struct TriangleShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> TriangleShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)

        return Path { path in
            path.move(to: CGPoint(x: insetRect.midX, y: insetRect.minY))
            path.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY))
            path.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY))
            path.closeSubpath()
        }
    }
}

struct DefaultCardColor {
    var red: Double
    var green: Double
    var blue: Double

    static let `default` = DefaultCardColor(red: 0.33, green: 0.54, blue: 0.99)

    init(red: Double, green: Double, blue: Double) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    init(hex: String) {
        var formatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if formatted.hasPrefix("#") {
            formatted.removeFirst()
        }

        if formatted.count == 6, let value = Int(formatted, radix: 16) {
            red = Double((value >> 16) & 0xFF) / 255.0
            green = Double((value >> 8) & 0xFF) / 255.0
            blue = Double(value & 0xFF) / 255.0
        } else {
            red = DefaultCardColor.default.red
            green = DefaultCardColor.default.green
            blue = DefaultCardColor.default.blue
        }
    }

    init(color: Color) {
        let rgb = color.toRGB()
        red = Double(rgb.red)
        green = Double(rgb.green)
        blue = Double(rgb.blue)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    var hexString: String {
        let r = Int(round(red * 255))
        let g = Int(round(green * 255))
        let b = Int(round(blue * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
