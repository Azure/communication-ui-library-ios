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
    let rttButton: DefaultButtonState?

    let callScreenCustomButtonsState: [CustomButtonState]
    /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
    let callScreenHeaderCustomButtonsState: [CustomButtonState]
    /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */

    init(setupScreenCameraButtonState: DefaultButtonState? = nil,
         setupScreenMicButtonState: DefaultButtonState? = nil,
         setupScreenAudioDeviceButtonState: DefaultButtonState? = nil,
         callScreenCameraButtonState: DefaultButtonState? = nil,
         callScreenMicButtonState: DefaultButtonState? = nil,
         callScreenAudioDeviceButtonState: DefaultButtonState? = nil,
         shareDiagnosticsButton: DefaultButtonState? = nil,
         reportIssueButton: DefaultButtonState? = nil,
         liveCaptionsButton: DefaultButtonState? = nil,
         liveCaptionsToggleButton: DefaultButtonState? = nil,
         spokenLanguageButton: DefaultButtonState? = nil,
         captionsLanguageButton: DefaultButtonState? = nil,
         rttButton: DefaultButtonState? = nil,
         callScreenCustomButtonsState: [CustomButtonState] = []
         /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
         ,
         callScreenHeaderCustomButtonsState: [CustomButtonState] = []
         /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
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
        self.rttButton = rttButton
        self.callScreenCustomButtonsState = callScreenCustomButtonsState
        /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
        self.callScreenHeaderCustomButtonsState = callScreenHeaderCustomButtonsState
        /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
    }

    static func constructInitial(setupScreenOptions: SetupScreenOptions?,
                                 callScreenOptions: CallScreenOptions?) -> ButtonViewDataState {
        return ButtonViewDataState(
            setupScreenCameraButtonState: DefaultButtonState(
                enabled: setupScreenOptions?.cameraButton?.enabled ?? true,
                visible: setupScreenOptions?.cameraButton?.visible ?? true),
            setupScreenMicButtonState: DefaultButtonState(
                enabled: setupScreenOptions?.microphoneButton?.enabled ?? true,
                visible: setupScreenOptions?.microphoneButton?.visible ?? true),
            setupScreenAudioDeviceButtonState: DefaultButtonState(
                enabled: setupScreenOptions?.audioDeviceButton?.enabled ?? true,
                visible: setupScreenOptions?.audioDeviceButton?.visible ?? true),

            callScreenCameraButtonState: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.cameraButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.cameraButton?.visible ?? true),
            callScreenMicButtonState: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.microphoneButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.microphoneButton?.visible ?? true),
            callScreenAudioDeviceButtonState: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.audioDeviceButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.audioDeviceButton?.visible ?? true),

            shareDiagnosticsButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.shareDiagnosticsButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.shareDiagnosticsButton?.visible ?? true),
            reportIssueButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.reportIssueButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.reportIssueButton?.visible ?? true),

            liveCaptionsButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.liveCaptionsButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.liveCaptionsButton?.visible ?? true),
            liveCaptionsToggleButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.liveCaptionsToggleButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.liveCaptionsToggleButton?.visible ?? true),
            spokenLanguageButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.spokenLanguageButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.spokenLanguageButton?.visible ?? true),
            captionsLanguageButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.captionsLanguageButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.captionsLanguageButton?.visible ?? true),
            rttButton: DefaultButtonState(
                enabled: callScreenOptions?.controlBarOptions?.rttButton?.enabled ?? true,
                visible: callScreenOptions?.controlBarOptions?.rttButton?.visible ?? true),
            callScreenCustomButtonsState: callScreenOptions?.controlBarOptions?.customButtons.map { customButton in
                return CustomButtonState(id: customButton.id,
                                  enabled: customButton.enabled,
                                  visible: customButton.visible,
                                  image: customButton.image,
                                  title: customButton.title)
            } ?? []
            /* <CALL_SCREEN_HEADER_CUSTOM_BUTTONS:0> */
            ,
            callScreenHeaderCustomButtonsState: callScreenOptions?.headerViewData?.customButtons.map { customButton in
                return CustomButtonState(id: customButton.id,
                                  enabled: customButton.enabled,
                                  visible: customButton.visible,
                                  image: customButton.image,
                                  title: customButton.title)
            } ?? []
            /* </CALL_SCREEN_HEADER_CUSTOM_BUTTONS> */
        )
    }
}
