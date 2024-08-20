//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Configuration options for customizing the call screen control bar.
public struct CallScreenControlBarOptions {
    /// Determines whether to display leave call confirmation. Default is enabled.
    public let leaveCallConfirmationMode: LeaveCallConfirmationMode

    public let cameraButton: ButtonOptions?
    public let microphoneButton: ButtonOptions?
    public let audioDeviceButton: ButtonOptions?
    public let liveCaptionsButtonOptions: ButtonOptions?
    public let liveCaptionsToggleButtonOptions: ButtonOptions?
    public let spokenLanguageButtonOptions: ButtonOptions?
    public let captionsLanguageButtonOptions: ButtonOptions?
    public let shareDiagnosticsButtonOptions: ButtonOptions?
    public let reportIssueButtonOptions: ButtonOptions?
    public let customButtons: [CustomButtonOptions]

    /// Initializes an instance of CallScreenControlBarOptions.
    /// - Parameters:
    ///   - leaveCallConfirmationMode: Whether to enable or disable the leave call confirmation.
    ///    Default is `.alwaysEnabled`.
    ///   - cameraButton: Configuration options for the camera button. Default is `nil`.
    ///   - microphoneButton: Configuration options for the microphone button. Default is `nil`.
    ///   - audioDeviceButton: Configuration options for the audio device button. Default is `nil`.
    ///   - liveCaptionsButtonOptions: Configuration options for the live captions button. Default is `nil`.
    ///   - liveCaptionsToggleButtonOptions: Configuration options for the live captions toggle button. 
    ///   Default is `nil`.
    ///   - spokenLanguageButtonOptions: Configuration options for the spoken language button. Default is `nil`.
    ///   - captionsLanguageButtonOptions: Configuration options for the captions language button. Default is `nil`.
    ///   - shareDiagnosticsButtonOptions: Configuration options for the share diagnostics button. Default is `nil`.
    ///   - reportIssueButtonOptions: Configuration options for the report issue button. Default is `nil`.
    ///   - customButtons: An array of custom button options. Default is an empty array.
    public init(leaveCallConfirmationMode: LeaveCallConfirmationMode = .alwaysEnabled,
                cameraButton: ButtonOptions? = nil,
                microphoneButton: ButtonOptions? = nil,
                audioDeviceButton: ButtonOptions? = nil,
                liveCaptionsButtonOptions: ButtonOptions? = nil,
                liveCaptionsToggleButtonOptions: ButtonOptions? = nil,
                spokenLanguageButtonOptions: ButtonOptions? = nil,
                captionsLanguageButtonOptions: ButtonOptions? = nil,
                shareDiagnosticsButtonOptions: ButtonOptions? = nil,
                reportIssueButtonOptions: ButtonOptions? = nil,
                customButtons: [CustomButtonOptions] = []
        ) {
            self.leaveCallConfirmationMode = leaveCallConfirmationMode
            self.cameraButton = cameraButton
            self.microphoneButton = microphoneButton
            self.audioDeviceButton = audioDeviceButton
            self.liveCaptionsButtonOptions = liveCaptionsButtonOptions
            self.liveCaptionsToggleButtonOptions = liveCaptionsToggleButtonOptions
            self.spokenLanguageButtonOptions = spokenLanguageButtonOptions
            self.captionsLanguageButtonOptions = captionsLanguageButtonOptions
            self.shareDiagnosticsButtonOptions = shareDiagnosticsButtonOptions
            self.reportIssueButtonOptions = reportIssueButtonOptions
            self.customButtons = customButtons
        }
}
