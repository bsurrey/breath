//
//  ResumableTimer.swift
//  breath
//
//  Created by Benjamin Surrey on 01.07.23.
//
import Foundation

class ResumableTimer: NSObject {

    private var timer: Timer? = Timer()
    private var callback: () -> Void

    private var startTime: TimeInterval?
    private var elapsedTime: TimeInterval?

    // MARK: Init

    init(interval: Double, callback: @escaping () -> Void) {
        self.callback = callback
        self.interval = interval
    }

    // MARK: API

    var isRepeatable: Bool = true
    var interval: Double = 1.0

    func isPaused() -> Bool {
        guard let timer = timer else { return false }
        return !timer.isValid
    }

    func start() {
        runTimer(interval: interval)
    }

    func pause() {
        elapsedTime = Date.timeIntervalSinceReferenceDate - (startTime ?? 0.0)
        timer?.invalidate()
    }

    func resume() {
        interval -= elapsedTime ?? 0.0
        runTimer(interval: interval)
    }

    func invalidate() {
        timer?.invalidate()
    }

    func reset() {
        startTime = Date.timeIntervalSinceReferenceDate
        runTimer(interval: interval)
    }

    // MARK: Private

    private func runTimer(interval: Double) {
        startTime = Date.timeIntervalSinceReferenceDate

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: isRepeatable) { [weak self] pos in
            self?.callback()
        }
    }
}

