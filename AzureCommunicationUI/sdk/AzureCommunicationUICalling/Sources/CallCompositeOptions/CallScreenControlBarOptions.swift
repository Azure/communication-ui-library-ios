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
    /// - Parameter leaveCallConfirmationMode: Whether to enable or disable the leave call confirmation.
    ///                                           Default is enabled.
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
