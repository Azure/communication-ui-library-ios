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
    case hideSupportForm
    case toastNotificationAction(ToastNotificationAction)
    case setTotalParticipantCount(Int)
}
