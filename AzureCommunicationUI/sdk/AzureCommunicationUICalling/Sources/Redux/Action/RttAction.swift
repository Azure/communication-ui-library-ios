//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum RttAction: Equatable {
    case turnOnRtt
    case sendRtt(message: String, isFinal: Bool)
    case updateMaximized(isMaximized: Bool)
}
