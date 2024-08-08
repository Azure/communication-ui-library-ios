//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureCommunicationCommon

/// User-configurable options for creating CallComposite.
public struct CallCompositeOptions {
    private(set) var themeOptions: ThemeOptions?
    private(set) var localizationOptions: LocalizationOptions?
    private(set) var enableMultitasking = false
    private(set) var enableSystemPipWhenMultitasking = false
    private(set) var setupScreenOrientation: OrientationOptions?
    private(set) var callingScreenOrientation: OrientationOptions?
    private(set) var callScreenOptions: CallScreenOptions?
    private(set) var capabilitiesChangedNotificationMode: CapabilitiesChangedNotificationMode?
    private(set) var callKitOptions: CallKitOptions?
    private(set) var disableInternalPushForIncomingCall = false
    private(set) var displayName: String?
    private(set) var userId: CommunicationIdentifier?
    private(set) var setupScreenOptions: SetupScreenOptions?

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    /// - Parameter setupScreenOrientation: setupScreenOrientation for specifying
    ///  setupScreenOrientation customization. Default value is `nil`.
    /// - Parameter callingScreenOrientation: callingScreenOrientation for specifying
    ///  callingScreenOrientation customization. Default value is `nil`.
    /// - Parameter enableMultitasking: enables user to navigate in the application
    ///  while on the call. Default value is `false`.
    /// - Parameter enableSystemPictureInPictureWhenMultitasking: enables syspem Picture-in-Picture while
    ///  enableMultitasking is on and user navigates away from call view. Default value is `false`.
    /// - Parameter callKitOptions: CallKitOptions for specifying CallKit customization. Default value is `nil`.
    /// - Parameter displayName: Display name for the user. Default value is `nil`.
    /// - Parameter disableInternalPushForIncomingCall: Disables internal push for incoming call.
    /// - Parameter userId: User Identifier is used for local avatar injection. Default value is `nil`
    @available(*, deprecated, message: "Use init without callScreenOptions and setupScreenOptions arguments.")
    public init(theme: ThemeOptions? = nil,
                localization: LocalizationOptions? = nil,
                setupScreenOrientation: OrientationOptions? = nil,
                callingScreenOrientation: OrientationOptions? = nil,
                enableMultitasking: Bool = false,
                enableSystemPictureInPictureWhenMultitasking: Bool = false,
                callScreenOptions: CallScreenOptions? = nil,
                callKitOptions: CallKitOptions? = nil,
                displayName: String? = nil,
                disableInternalPushForIncomingCall: Bool = false,
                setupScreenOptions: SetupScreenOptions? = nil,
                capabilitiesChangedNotificationMode: CapabilitiesChangedNotificationMode? = nil,
                userId: CommunicationIdentifier? = nil
            ) {
        self.themeOptions = theme
        self.localizationOptions = localization
        self.setupScreenOrientation = setupScreenOrientation
        self.callingScreenOrientation = callingScreenOrientation
        self.enableMultitasking = enableMultitasking
        self.enableSystemPipWhenMultitasking = enableSystemPictureInPictureWhenMultitasking
        self.callScreenOptions = callScreenOptions
        self.capabilitiesChangedNotificationMode = capabilitiesChangedNotificationMode
        self.callKitOptions = callKitOptions
        self.displayName = displayName
        self.setupScreenOptions = setupScreenOptions
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        self.userId = userId
    }

    /// Creates an instance of CallCompositeOptions with related options.
    /// - Parameter theme: ThemeOptions for changing color pattern.
    ///  Default value is `nil`.
    /// - Parameter localization: LocalizationOptions for specifying
    ///  localization customization. Default value is `nil`.
    /// - Parameter setupScreenOrientation: setupScreenOrientation for specifying
    ///  setupScreenOrientation customization. Default value is `nil`.
    /// - Parameter callingScreenOrientation: callingScreenOrientation for specifying
    ///  callingScreenOrientation customization. Default value is `nil`.
    /// - Parameter enableMultitasking: enables user to navigate in the application
    ///  while on the call. Default value is `false`.
    /// - Parameter enableSystemPictureInPictureWhenMultitasking: enables syspem Picture-in-Picture while
    ///  enableMultitasking is on and user navigates away from call view. Default value is `false`.
    /// - Parameter callKitOptions: CallKitOptions for specifying CallKit customization. Default value is `nil`.
    /// - Parameter displayName: Display name for the user. Default value is `nil`.
    /// - Parameter disableInternalPushForIncomingCall: Disables internal push for incoming call.
    /// - Parameter userId: User Identifier is used for local avatar injection. Default value is `nil`
    public init(theme: ThemeOptions? = nil,
                localization: LocalizationOptions? = nil,
                setupScreenOrientation: OrientationOptions? = nil,
                callingScreenOrientation: OrientationOptions? = nil,
                enableMultitasking: Bool = false,
                enableSystemPictureInPictureWhenMultitasking: Bool = false,
                callKitOptions: CallKitOptions? = nil,
                displayName: String? = nil,
                disableInternalPushForIncomingCall: Bool = false,
                capabilitiesChangedNotificationMode: CapabilitiesChangedNotificationMode? = nil,
                userId: CommunicationIdentifier? = nil
            ) {
        self.themeOptions = theme
        self.localizationOptions = localization
        self.setupScreenOrientation = setupScreenOrientation
        self.callingScreenOrientation = callingScreenOrientation
        self.enableMultitasking = enableMultitasking
        self.enableSystemPipWhenMultitasking = enableSystemPictureInPictureWhenMultitasking
        self.callScreenOptions = nil
        self.capabilitiesChangedNotificationMode = capabilitiesChangedNotificationMode
        self.callKitOptions = callKitOptions
        self.displayName = displayName
        self.setupScreenOptions = nil
        self.disableInternalPushForIncomingCall = disableInternalPushForIncomingCall
        self.userId = userId
    }
}
