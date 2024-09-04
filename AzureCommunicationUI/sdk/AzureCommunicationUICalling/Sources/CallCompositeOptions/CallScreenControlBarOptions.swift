//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Configuration options for customizing the call screen control bar.
public struct CallScreenControlBarOptions {
    /// Determines whether to display leave call confirmation. Default is enabled.
    public let leaveCallConfirmationMode: LeaveCallConfirmationMode

    public let cameraButton: ButtonViewData?
    public let microphoneButton: ButtonViewData?
    public let audioDeviceButton: ButtonViewData?
    public let liveCaptionsButton: ButtonViewData?
    public let liveCaptionsToggleButton: ButtonViewData?
    public let spokenLanguageButton: ButtonViewData?
    public let captionsLanguageButton: ButtonViewData?
    public let shareDiagnosticsButton: ButtonViewData?
    public let reportIssueButton: ButtonViewData?
    public let customButtons: [CustomButtonViewData]

    /// Initializes an instance of CallScreenControlBarOptions.
    /// - Parameters:
    ///   - leaveCallConfirmationMode: Whether to enable or disable the leave call confirmation.
    ///    Default is `.alwaysEnabled`.
    ///   - cameraButton: Configuration view data for the camera button. Default is `nil`.
    ///   - microphoneButton: Configuration view data for the microphone button. Default is `nil`.
    ///   - audioDeviceButton: Configuration view data for the audio device button. Default is `nil`.
    ///   - liveCaptionsButton: Configuration view data for the live captions button. Default is `nil`.
    ///   - liveCaptionsToggleButton: Configuration view data for the live captions toggle button.
    ///   Default is `nil`.
    ///   - spokenLanguageButton: Configuration view data for the spoken language button. Default is `nil`.
    ///   - captionsLanguageButton: Configuration view data for the captions language button. Default is `nil`.
    ///   - shareDiagnosticsButton: Configuration view data for the share diagnostics button. Default is `nil`.
    ///   - reportIssueButton: Configuration view data for the report issue button. Default is `nil`.
    ///   - customButtons: An array of custom button options. Default is an empty array.
    public init(leaveCallConfirmationMode: LeaveCallConfirmationMode = .alwaysEnabled,
                cameraButton: ButtonViewData? = nil,
                microphoneButton: ButtonViewData? = nil,
                audioDeviceButton: ButtonViewData? = nil,
                liveCaptionsButton: ButtonViewData? = nil,
                liveCaptionsToggleButton: ButtonViewData? = nil,
                spokenLanguageButton: ButtonViewData? = nil,
                captionsLanguageButton: ButtonViewData? = nil,
                shareDiagnosticsButton: ButtonViewData? = nil,
                reportIssueButton: ButtonViewData? = nil,
                customButtons: [CustomButtonViewData] = []
        ) {
            self.leaveCallConfirmationMode = leaveCallConfirmationMode
            self.cameraButton = cameraButton
            self.microphoneButton = microphoneButton
            self.audioDeviceButton = audioDeviceButton
            self.liveCaptionsButton = liveCaptionsButton
            self.liveCaptionsToggleButton = liveCaptionsToggleButton
            self.spokenLanguageButton = spokenLanguageButton
            self.captionsLanguageButton = captionsLanguageButton
            self.shareDiagnosticsButton = shareDiagnosticsButton
            self.reportIssueButton = reportIssueButton
            self.customButtons = customButtons
        }
}
