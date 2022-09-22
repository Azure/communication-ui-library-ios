//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationUICalling
import AzureCommunicationUIChat

extension LocalOptions {
    func getCallCompositeLocalOptions() -> AzureCommunicationUICalling.LocalOptions {
        let participantViewData = participantViewData.getCallCompositeParticipantViewData()
        return AzureCommunicationUICalling.LocalOptions(participantViewData: participantViewData)
    }

    func getChatCompositeLocalOptions() -> AzureCommunicationUIChat.LocalOptions {
        let participantViewData = participantViewData.getChatCompositeParticipantViewData()
        return AzureCommunicationUIChat.LocalOptions(participantViewData: participantViewData)
    }
}

extension ThemeOptions {
    func getCallCompositeThemeOptions() -> AzureCommunicationUICalling.ThemeOptions {
        return CallCompositeThemeOptions(themeOptions: self)
    }

    func getChatCompositeThemeOptions() -> AzureCommunicationUIChat.ThemeOptions {
        return ChatCompositeThemeOptions(themeOptions: self)
    }
}

extension LocalizationOptions {
    func getCallCompositeLocalizationOptions() -> AzureCommunicationUICalling.LocalizationOptions {
        return AzureCommunicationUICalling.LocalizationOptions(locale: Locale(identifier: languageCode),
                                                               localizableFilename: localizableFilename,
                                                               layoutDirection: layoutDirection)
    }

    func getChatCompositeLocalizationOptions() -> AzureCommunicationUIChat.LocalizationOptions {
        return AzureCommunicationUIChat.LocalizationOptions(locale: Locale(identifier: languageCode),
                                                            localizableFilename: localizableFilename,
                                                            layoutDirection: layoutDirection)
    }
}

/// Object to represent participants data
extension ParticipantViewData {
    func getCallCompositeParticipantViewData() -> AzureCommunicationUICalling.ParticipantViewData {
        return AzureCommunicationUICalling.ParticipantViewData(avatar: avatarImage,
                                                               displayName: displayName)
    }

    func getChatCompositeParticipantViewData() -> AzureCommunicationUIChat.ParticipantViewData {
        return AzureCommunicationUIChat.ParticipantViewData(avatar: avatarImage,
                                                               displayName: displayName)
    }
}

struct CallCompositeThemeOptions: AzureCommunicationUICalling.ThemeOptions {
    let themeOptions: ThemeOptions

    var colorSchemeOverride: UIUserInterfaceStyle {
        return themeOptions.colorSchemeOverride
    }

    /// Provide a getter to return a custom primary color.
    var primaryColor: UIColor { return themeOptions.primaryColor }

    /// Provide a getter to return a custom primary color tint10.
    var primaryColorTint10: UIColor { return themeOptions.primaryColorTint10 }

    /// Provide a getter to return a custom primary color tint20.
    var primaryColorTint20: UIColor { return themeOptions.primaryColorTint20 }

    /// Provide a getter to return a custom primary color tint30.
    var primaryColorTint30: UIColor { return themeOptions.primaryColorTint30 }
}

struct ChatCompositeThemeOptions: AzureCommunicationUIChat.ThemeOptions {
    let themeOptions: ThemeOptions

    var colorSchemeOverride: UIUserInterfaceStyle {
        return themeOptions.colorSchemeOverride
    }

    /// Provide a getter to return a custom primary color.
    var primaryColor: UIColor { return themeOptions.primaryColor }

    /// Provide a getter to return a custom primary color tint10.
    var primaryColorTint10: UIColor { return themeOptions.primaryColorTint10 }

    /// Provide a getter to return a custom primary color tint20.
    var primaryColorTint20: UIColor { return themeOptions.primaryColorTint20 }

    /// Provide a getter to return a custom primary color tint30.
    var primaryColorTint30: UIColor { return themeOptions.primaryColorTint30 }
}
