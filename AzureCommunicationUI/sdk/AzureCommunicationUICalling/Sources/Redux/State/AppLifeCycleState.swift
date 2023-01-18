//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

enum AppStatus {
    case foreground
    case background
    case willTerminate
}

struct LifeCycleState {

    let currentStatus: AppStatus

    init(currentStatus: AppStatus = .foreground) {
        self.currentStatus = currentStatus
    }
}

struct AppPhaseKey: EnvironmentKey {
    static let defaultValue: AppStatus = .foreground
}

extension EnvironmentValues {
    var appPhase: AppStatus {
        get { self[AppPhaseKey.self] }
        set { self[AppPhaseKey.self] = newValue }
    }
}
