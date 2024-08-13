//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallTimerAPI {
    func onStart()
    func onStop()
    func onReset()
}

class CallDurationManager: CallTimerAPI, ObservableObject {
    private var timer: Timer?
    private var timeRemaining: TimeInterval = 60 // 1 minute in seconds
    private var isPaused = false
    @Published var timerTickStateFlow: String = ""
    var isStarted = false

    init() {
        // Timer is not started in init, it will be started in onStart
    }

    func onStart() {
        startTimer()
        isStarted = true
    }

    func onStop() {
        timer?.invalidate()
        timer = nil
    }

    func onReset() {
        timer?.invalidate()
        timeRemaining = 60
        timerTickStateFlow = "00:00"
        startTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.timeRemaining -= 1
            let secondsElapsed = 60 - self.timeRemaining
            self.timerTickStateFlow = String(format: "%02d:%02d", Int(secondsElapsed) / 60, Int(secondsElapsed) % 60)
            if self.timeRemaining <= 0 {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}
