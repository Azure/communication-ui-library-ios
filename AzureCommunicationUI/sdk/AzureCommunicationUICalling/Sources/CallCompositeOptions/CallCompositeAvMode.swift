//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the mode of audio and video in a call.
public enum CallCompositeAvMode {
    /// - `normal`: Both audio and video are enabled.
    case normal
    /// - `audioOnly`: Only audio is enabled, no video, except for "shared content".
    case audioOnly
    /// `rawValue` provides a `String` representation of the mode:
    /// - For `.normal`, it returns "normal".
    /// - For `.audioOnly`, it returns "audioOnly".
    var rawValue: String {
        switch self {
        case .normal:
            return "normal"
        case .audioOnly:
            return "audioOnly"
        }
    }
}
