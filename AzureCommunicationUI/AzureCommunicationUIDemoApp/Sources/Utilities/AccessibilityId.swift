//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AccessibilityId: String {
    /* DemoView */
    case startExperienceAccessibilityID =
            "AzureCommunicationUICalling.DemoView.StartExperience.AccessibilityID"
    case showExperienceAccessibilityID =
            "AzureCommunicationUICalling.DemoView.ShowExperience.AccessibilityID"
    case registerPushAccessibilityID =
            "AzureCommunicationUICalling.DemoView.RegisterPush.AccessibilityID"
    case unregisterPushAccessibilityID =
            "AzureCommunicationUICalling.DemoView.UnregisterPush.AccessibilityID"
    case acceptCallAccessibilityID =
            "AzureCommunicationUICalling.DemoView.AcceptCall.AccessibilityID"
    case declineCallAccessibilityID =
            "AzureCommunicationUICalling.DemoView.DeclineCall.AccessibilityID"
    case clearTokenTextFieldAccessibilityID =
            "AzureCommunicationUICalling.DemoView.ClearTokenTextField.AccessibilityID"
    case settingsButtonAccessibilityID =
            "AzureCommunicationUICalling.DemoView.Settings.AccessibilityID"

    case startHeadlessAccessibilityID =
            "AzureCommunicationUIChat.DemoView.StartHeadless.AccessibilityID"
    case showChatUIAccessibilityID =
            "AzureCommunicationUIChat.DemoView.ShowChatUI.AccessibilityID"
    case stopChatAccessibilityID =
            "AzureCommunicationUIhat.DemoView.StopChat.AccessibilityID"

    /* SettingsView */
    case expiredAcsTokenToggleAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.expiredAcstokenToggle.AccessibilityID"
    case useMockCallingSDKHandlerToggleAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.useMockCallingSDKHandler.AccessibilityID"
    case settingsCloseButtonAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.CloseButton.AccessibilityID"
    case useRelaunchOnDismissedToggleToggleAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.useRelaunchOnDismissed.AccessibilityID"
    case toggleAudioOnlyModeAccessibilityID = "AzureCommunicationUICalling.SettingsView.AudioOnly.AccessibilityID"
    case userReportedIssueAccessibilityID = "AzureCommunicationUICalling.Launcher.UserFeedback"
    case leaveCallConfirmationDisplayAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.leaveCallConfirmationDisplay.AccessibilityID"
    case useEnableCalkitToggleToggleAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.enableCalkitToggle.AccessibilityID"
    case useEnableRemoteHoldToggleToggleAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.enableRemoteHoldToggle.AccessibilityID"
    case useEnableRemoteInfoToggleToggleAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.enableRemoteInfoToggle.AccessibilityID"

    case setupScreenCameraButtonEnabledAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.setupScreenCameraButtonEnabled.AccessibilityID"

    case setupScreenMicButtonEnabledAccessibilityID =
            "AzureCommunicationUICalling.SettingsView.setupScreenMicButtonEnabled.AccessibilityID"

}
