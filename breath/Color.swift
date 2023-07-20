//
//  Color.swift
//  breath
//
//  Created by Benjamin Surrey on 09.07.23.
//

import Foundation
import SwiftUI

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
}
