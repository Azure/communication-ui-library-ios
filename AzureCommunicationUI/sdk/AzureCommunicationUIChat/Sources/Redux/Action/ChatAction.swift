//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatAction: Equatable {
    case chatStartRequested

    static func == (lhs: ChatAction, rhs: ChatAction) -> Bool {
        switch (lhs, rhs) {
        case (.chatStartRequested, .chatStartRequested):
            return true
        default:
            return false
        }
    }
}
