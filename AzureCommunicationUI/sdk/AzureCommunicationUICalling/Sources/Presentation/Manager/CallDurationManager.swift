//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol CallTimerAPI {
    var timerString: String {get set}
    func onStart()
    func onStop()
    func onReset()
}

class CallDurationManager: CallTimerAPI, ObservableObject {
    @Published var timerString: String = ""
    private var timer: Timer?
    var timeElapsed: TimeInterval? = 0
    @Published var timerTickStateFlow: String = ""
    var isStarted = false

    init(timeElapsed: TimeInterval? = 0) {
        // Timer is not started in init, it will be started in onStart
        self.timeElapsed = timeElapsed ?? 0
    }

    func onStart() {
        startTimer()
        isStarted = true
    }

    func onStop() {
        timer?.invalidate()
        timer = nil
        isStarted = false
        timeElapsed = 0
        timerString = formatTime(timeElapsed!)
    }

    func onReset() {
        timer?.invalidate()
        timeElapsed = 0
        timerTickStateFlow = "00:00"
        timerString = formatTime(timeElapsed!)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            timeElapsed! += 1
            timerTickStateFlow = String(format: "%02d:%02d", Int(timeElapsed!) / 60, Int(timeElapsed!) % 60)
            if timeElapsed! > 3600 {
                timerTickStateFlow = String(format: "%02d:%02d:%02d", Int(timeElapsed!) / 3600, Int(timeElapsed!) / 60,
                                            Int(timeElapsed!) % 60)
            }
            timerString = formatTime(timeElapsed!)
        }
    }
     func formatTime(_ timeElapsed: TimeInterval) -> String {
        let hours = Int(timeElapsed) / 3600
        let minutes = (Int(timeElapsed) % 3600) / 60
        let seconds = Int(timeElapsed) % 60
        if hours > 0 {
            return "\(hours) hours \(minutes) minutes \(seconds) seconds"
        } else if minutes > 0 {
            return "\(minutes) minutes \(seconds) seconds"
        } else {
            return "\(seconds) seconds"
        }
    }
}
