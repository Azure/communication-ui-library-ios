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
    case videoAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.Video.AccessibilityID"
    case micAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.Microphone.AccessibilityID"
    case audioDeviceAccessibilityID =
            "AzureCommunicationUICalling.CallingView.ControlButton.AudioDevice.AccessibilityID"
    case hangupAccessibilityID = "AzureCommunicationUICalling.CallingView.ControlButton.HangUp.AccessibilityID"
    case cancelAccessibilityID = "AzureCommunicationUICalling.CallingView.Overlay.Cancel.AccssibilityID"
}
