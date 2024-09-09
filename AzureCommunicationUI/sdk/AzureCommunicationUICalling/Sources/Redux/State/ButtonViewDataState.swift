//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

struct DefaultButtonState: Equatable {
    let enabled: Bool
    let visible: Bool
}

struct CustomButtonState: Equatable {
    let id: String
    let enabled: Bool
    let visible: Bool
    let image: UIImage
    let title: String
}

struct ButtonViewDataState: Equatable {
    let setupScreenCameraButtonState: DefaultButtonState?
    let setupScreenMicButtonState: DefaultButtonState?
    let setupScreenAudioDeviceButtonState: DefaultButtonState?

    let callScreenCameraButtonState: DefaultButtonState?
    let callScreenMicButtonState: DefaultButtonState?
    let callScreenAudioDeviceButtonState: DefaultButtonState?

    let liveCaptionsButton: DefaultButtonState?
    let liveCaptionsToggleButton: DefaultButtonState?
    let spokenLanguageButton: DefaultButtonState?
    let captionsLanguageButton: DefaultButtonState?
    let shareDiagnosticsButton: DefaultButtonState?
    let reportIssueButton: DefaultButtonState?

    let callScreenCustomButtonsState: [CustomButtonState]

    init(setupScreenCameraButtonState: DefaultButtonState? = nil,
         setupScreenMicButtonState: DefaultButtonState? = nil,
         setupScreenAudioDeviceButtonState: DefaultButtonState? = nil,
         callScreenCameraButtonState: DefaultButtonState? = nil,
         callScreenMicButtonState: DefaultButtonState? = nil,
         callScreenAudioDeviceButtonState: DefaultButtonState? = nil,
         liveCaptionsButton: DefaultButtonState? = nil,
         liveCaptionsToggleButton: DefaultButtonState? = nil,
         spokenLanguageButton: DefaultButtonState? = nil,
         captionsLanguageButton: DefaultButtonState? = nil,
         shareDiagnosticsButton: DefaultButtonState? = nil,
         reportIssueButton: DefaultButtonState? = nil,
         callScreenCustomButtonsState: [CustomButtonState] = []
    ) {
        self.setupScreenCameraButtonState = setupScreenCameraButtonState
        self.setupScreenMicButtonState = setupScreenMicButtonState
        self.setupScreenAudioDeviceButtonState = setupScreenAudioDeviceButtonState

        self.callScreenCameraButtonState = callScreenCameraButtonState
        self.callScreenMicButtonState = callScreenMicButtonState
        self.callScreenAudioDeviceButtonState = callScreenAudioDeviceButtonState

        self.liveCaptionsButton = liveCaptionsButton
        self.liveCaptionsToggleButton = liveCaptionsToggleButton
        self.spokenLanguageButton = spokenLanguageButton
        self.captionsLanguageButton = captionsLanguageButton
        self.shareDiagnosticsButton = shareDiagnosticsButton
        self.reportIssueButton = reportIssueButton

        self.callScreenCustomButtonsState = callScreenCustomButtonsState
    }
}
