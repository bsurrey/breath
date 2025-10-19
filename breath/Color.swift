//
//  Color.swift
//  breath
//
//  Created by Benjamin Surrey on 09.07.23.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    // Transform SwiftUI Color to Exercise RGB Floats
    func toRGB() -> (red: Float, green: Float, blue: Float) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Float(red), Float(green), Float(blue))
    }
    
    // Construct a SwiftUI Color from Exercise RGB Floats
    static func fromRGB(red: Float, green: Float, blue: Float) -> Color {
        return Color(UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0))
    }

    /// Returns a lighter variant of the color by blending in the given percentage of white.
    func lighter(by amount: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let clamp: (CGFloat) -> CGFloat = { min(max($0, 0), 1) }
        let newRed = clamp(red + (1 - red) * amount)
        let newGreen = clamp(green + (1 - green) * amount)
        let newBlue = clamp(blue + (1 - blue) * amount)

        return Color(red: Double(newRed), green: Double(newGreen), blue: Double(newBlue), opacity: Double(alpha))
    }

    /// Perceived brightness in range 0...1 using the WCAG relative luminance formula.
    var perceivedBrightness: CGFloat {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        func component(_ value: CGFloat) -> CGFloat {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }

        let r = component(red)
        let g = component(green)
        let b = component(blue)
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// Simple heuristic for determining if a color is visually light.
    var isVisuallyLight: Bool {
        perceivedBrightness > 0.6
    }
}
