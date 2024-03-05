//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the mode of audio and video in a call.
public enum CallCompositeAudioVideoMode {
    /// - `audioAndVideo`: Both audio and video are enabled.
    case audioAndVideo
    /// - `audioOnly`: Only audio is enabled, no video, except for "shared content".
    case audioOnly
    /// `rawValue` provides a `String` representation of the mode:
    /// - For `.audioAndVideo`, it returns "audioAndVideo".
    /// - For `.audioOnly`, it returns "audioOnly".
    var rawValue: String {
        switch self {
        case .audioAndVideo:
            return "audioAndVideo"
        case .audioOnly:
            return "audioOnly"
        }
    }
}
