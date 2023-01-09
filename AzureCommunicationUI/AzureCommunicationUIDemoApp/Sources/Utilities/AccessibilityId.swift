//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum AccessibilityId: String {
    /* DemoView */
    case startExperienceAccessibilityID =
            "AzureCommunicationUICalling.DemoView.StartExperience.AccessibilityID"
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
}
