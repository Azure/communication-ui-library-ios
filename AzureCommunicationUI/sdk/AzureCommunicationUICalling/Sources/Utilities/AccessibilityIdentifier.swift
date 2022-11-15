//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AccessibilityIdentifier: String {
    case leaveCallAccessibilityID = "AzureCommunicationUICalling.CallingView.Overlay.LeaveCall.AccessibilityID"
    case joinCallAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.JoinCall.AccessibilityID"
    case toggleVideoAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Video.AccessibilityID"
    case togglMicAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Mic.AccessibilityID"
    case toggleAudioDeviceAccesibiiltyID = "AzureCommunicationUICalling.SetupView.Button.AudioDevice.AccessibilityID"
    case dismisButtonAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Dismiss.AccessibilityID"
    case goToSettingsAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.GoToSettings.AccessibilityID"
    case videoAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.Video.AccessibilityID"
    case micAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.Microphone.AccessibilityID"
    case audioDeviceAccessibilityID =
            "AzureCommunicationUICalling.CallingView.ControlButton.AudioDevice.AccessibilityID"
    case hangupAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.HangUp.AccessibilityID"
    case cancelAccessibilityID = "AzureCommunicationUICalling.CallingView.Overlay.Cancel.AccessibilityID"
    case uitestSettingsLaunchButton = "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.LaunchButton"
    case uitestsimulateCallOnHold = "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateCallOnHold"
    case uitestsimulateCallOnResume =
            "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateCallResume"
    case uitestsimulateRecordingStart =
            "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateRecordingStart"
    case uitestsimulateRecordingEnd =
            "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateRecordingEnd"
    case uitestsimulateTranscriptionStart =
            "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateTranscriptionStart"
    case uitestsimulateTranscriptionEnd =
            "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateTranscriptionEnd"
    case uitestsimulateNewParticipantJoin =
            "AzureCommunicationUICalling.CallingView.Overlay.UITestSettings.SimulateNewParticipantJoin"
    case moreAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.More.AccessibilityID"
    case shareDiagnosticsAccessibilityID =
            "AzureCommunicationUICalling.CallingView.MoreOverlay.ShareDiagnostics.AccessibilityID"
    case activityViewControllerCloseButtonAccessibilityID =
            "Close"
    case activityViewControllerCopyButtonAccessibilityID =
            "Copy"
    case activityViewControllerAccessibilityID =
            "ActivityListView"
}
