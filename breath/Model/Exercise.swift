//
//  Exercise.swift
//  breath
//
//  Created by Benjamin Surrey on 20.10.25.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var uuid: UUID
    var title: String
    var breathingInDuration: Double
    var breathingOutDuration: Double
    var repetitions: Int
    var animations: Bool
    var createdTime: Date
    var updatedTime: Date
    var red: Float
    var green: Float
    var blue: Float
    var color: String
    var favorite: Bool

    init(
        uuid: UUID = UUID(),
        title: String = "Exercise",
        breathingInDuration: Double = 4.0,
        breathingOutDuration: Double = 6.0,
        repetitions: Int = 5,
        animations: Bool = true,
        createdTime: Date = .now,
        updatedTime: Date = .now,
        red: Float = 0.28,
        green: Float = 0.56,
        blue: Float = 0.86,
        color: String = "",
        favorite: Bool = false
    ) {
        self.uuid = uuid
        self.title = title
        self.breathingInDuration = breathingInDuration
        self.breathingOutDuration = breathingOutDuration
        self.repetitions = repetitions
        self.animations = animations
        self.createdTime = createdTime
        self.updatedTime = updatedTime
        self.red = red
        self.green = green
        self.blue = blue
        self.color = color
        self.favorite = favorite
    }

}
