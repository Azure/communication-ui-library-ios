//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

///
/// Actions for the entire library. All actions are defined here as a heirarchy of enum types
/// 
enum Actions {
    case audioSessionAction(AudioSessionAction)
    case callingAction(CallingAction)
    case errorAction(ErrorAction)
    case lifecycleAction(LifecycleAction)
    case localUserAction(LocalUserAction)
    case permissionAction(PermissionAction)
}
