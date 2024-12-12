//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

enum ButtonViewDataAction: Equatable {

    case callScreenCameraButtonIsEnabledUpdated(enabled: Bool)
    case callScreenCameraButtonIsVisibleUpdated(visible: Bool)
    case callScreenMicButtonIsEnabledUpdated(enabled: Bool)
    case callScreenMicButtonIsVisibleUpdated(visible: Bool)

    case callScreenAudioDeviceButtonIsEnabledUpdated(enabled: Bool)
    case callScreenAudioDeviceButtonIsVisibleUpdated(visible: Bool)

    case callScreenLiveCaptionsButtonIsEnabledUpdated(enabled: Bool)
    case callScreenLiveCaptionsButtonIsVisibleUpdated(visible: Bool)

    case callScreenLiveCaptionsToggleButtonIsEnabledUpdated(enabled: Bool)
    case callScreenLiveCaptionsToggleButtonIsVisibleUpdated(visible: Bool)

    case callScreenSpokenLanguageButtonIsEnabledUpdated(enabled: Bool)
    case callScreenSpokenLanguageButtonIsVisibleUpdated(visible: Bool)

    case callScreenCaptionsLanguageButtonIsEnabledUpdated(enabled: Bool)
    case callScreenCaptionsLanguageButtonIsVisibleUpdated(visible: Bool)

    case callScreenShareDiagnosticsButtonIsEnabledUpdated(enabled: Bool)
    case callScreenShareDiagnosticsButtonIsVisibleUpdated(visible: Bool)

    case callScreenReportIssueButtonIsEnabledUpdated(enabled: Bool)
    case callScreenReportIssueButtonIsVisibleUpdated(visible: Bool)

    case callScreenCustomButtonIsEnabledUpdated(id: String, enabled: Bool)
    case callScreenCustomButtonIsVisibleUpdated(id: String, visible: Bool)
    case callScreenCustomButtonTitleUpdated(id: String, title: String)
    case callScreenCustomButtonIconUpdated(id: String, image: UIImage)
    case callScreenHeaderCustomButtonIsEnabledUpdated(id: String, enabled: Bool)
    case callScreenHeaderCustomButtonIsVisibleUpdated(id: String, visible: Bool)
    case callScreenHeaderCustomButtonTitleUpdated(id: String, title: String)
    case callScreenHeaderCustomButtonIconUpdated(id: String, image: UIImage)
    case setupScreenCameraButtonIsEnabledUpdated(enabled: Bool)
    case setupScreenCameraButtonIsVisibleUpdated(visible: Bool)
    case setupScreenMicButtonIsEnabledUpdated(enabled: Bool)
    case setupScreenMicButtonIsVisibleUpdated(visible: Bool)
    case setupScreenAudioDeviceButtonIsEnabledUpdated(enabled: Bool)
    case setupScreenAudioDeviceButtonIsVisibleUpdated(visible: Bool)

}
