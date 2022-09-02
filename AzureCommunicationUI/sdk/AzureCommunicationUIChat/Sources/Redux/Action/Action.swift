//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

///
/// Action for the entire library. All actions are defined here as a heirarchy of enum types
///
enum Action: Equatable {
    case lifecycleAction(LifecycleAction)
    case compositeExitAction
    case chatViewLaunched
    case chatViewHeadless
}
