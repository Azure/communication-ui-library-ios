//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AccessibilityIdentifier: String {
    /* DemoView */
    case startExperience = "AzureCommunicationUICalling.DemoView.StartExperience"
    case startExperienceAccessibilityLabel = "AzureCommunicationUICalling.DemoView.StartExperience.AccessibilityLabel"
    case clearTokenTextFieldAccessibilityLabel =
            "AzureCommunicationUICalling.DemoView.ClearTokenTextField.AccessibilityLabel"

    case joinCallAccessibilityLabel = "AzureCommunicationUICalling.SetupView.Button.JoinCall.AccessibilityID"
    case toggleVideoAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Video.AccessibilityID"
    case togglMicAccessibilityID = "AzureCommunicationUICalling.SetupView.Button.Mic.AccessibilityID"
    case videoAccessibilityLabel = "AzureCommunicationUICalling.CallingView.ControlButton.Video.AccessibilityID"
    case micAccessibilityLabel = "AzureCommunicationUICalling.CallingView.ControlButton.Microphone.AccessibilityID"
    case audioDeviceAccessibilityLabel =
            "AzureCommunicationUICalling.CallingView.ControlButton.AudioDevice.AccessibilityID"
    case hangupAccessibilityLabel = "AzureCommunicationUICalling.CallingView.ControlButton.HangUp.AccessibilityID"
    case cancelAccssibilityLabel = "AzureCommunicationUICalling.CallingView.Overlay.Cancel.AccssibilityID"
}
