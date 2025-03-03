//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

///
/// Action for the entire library. All actions are defined here as a hierarchy of enum types
/// 
enum Action: Equatable {
    case audioSessionAction(AudioSessionAction)
    case callingAction(CallingAction)
    case errorAction(ErrorAction)
    case lifecycleAction(LifecycleAction)
    case visibilityAction(VisibilityAction)
    case localUserAction(LocalUserAction)
    case permissionAction(PermissionAction)
    case remoteParticipantsAction(RemoteParticipantsAction)
    case callDiagnosticAction(DiagnosticsAction)
    case compositeExitAction
    case callingViewLaunched
    case showSupportForm
    case showCaptionsRttListView
    case showSpokenLanguageView
    case showCaptionsLanguageView
    case captionsAction(CaptionsAction)
    case rttAction(RttAction)
    case showEndCallConfirmation
    case showAudioSelection
    case showMoreOptions
    case showSupportShare
    case showParticipants
    case showParticipantActions(ParticipantInfoModel)
    // Since we only show one drawer at a time, we can have one hide
    case hideDrawer

    case toastNotificationAction(ToastNotificationAction)
    case setTotalParticipantCount(Int)
    case callScreenInfoHeaderAction(CallScreenInfoHeaderAction)
    case buttonViewDataAction(ButtonViewDataAction)
}
