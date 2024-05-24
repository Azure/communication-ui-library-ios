//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// An error that occurs on incoming call accept/decline.
public enum IncomingCallError: String, Error {
    /// call id not found.
    case callIdNotFound
}
