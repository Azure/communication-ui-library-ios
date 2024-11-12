//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation

struct RttState: Equatable {
    var isRttOn: Bool

    init(isEnabled: Bool = false) {
        self.isRttOn = isEnabled
    }
}
