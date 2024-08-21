/* <TIMER_TITLE_FEATURE>
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
    @Published var timeElapsed: TimeInterval = 0
    private var timer: Timer?
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
    }

    func onReset() {
        timer?.invalidate()
        timeElapsed = 0
        timerTickStateFlow = "00:00"
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            timeElapsed += 1
            timerTickStateFlow = String(format: "%02d:%02d", Int(timeElapsed) / 60, Int(timeElapsed) % 60)
            if timeElapsed > 3600 {
                timerTickStateFlow = String(format: "%02d:%02d:%02d", Int(timeElapsed) / 3600, Int(timeElapsed) / 60,
                                            Int(timeElapsed) % 60)
            }
        }
    }
}
</TIMER_TITLE_FEATURE> */
