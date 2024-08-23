/* <TIMER_TITLE_FEATURE> */
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
    var timer: Timer?
    @Published var timerTickStateFlow: String = ""
    var isStarted = false

    init(timeElapsed: TimeInterval? = 0) {
        // Timer is not started in init, it will be started in onStart
        self.timeElapsed = timeElapsed ?? 0
    }

    func onStart() {
        startTimer()
        self.isStarted = true
    }

    func onStop() {
        self.timer?.invalidate()
        self.timer = nil
        self.isStarted = false
        self.timeElapsed = 0
    }

    func onReset() {
        self.timer?.invalidate()
        self.timeElapsed = 0
        self.timerTickStateFlow = "00:00"
    }

    private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.timeElapsed += 1
            self.timerTickStateFlow = String(format: "%02d:%02d", Int(self.timeElapsed) / 60, Int(self.timeElapsed) % 60)
            if self.timeElapsed > 3600 {
                self.timerTickStateFlow = String(format: "%02d:%02d:%02d",
                                            Int(self.timeElapsed) / 3600, Int(self.timeElapsed) / 60,
                                            Int(self.timeElapsed) % 60)
            }
        }
    }
}
/* </TIMER_TITLE_FEATURE> */
