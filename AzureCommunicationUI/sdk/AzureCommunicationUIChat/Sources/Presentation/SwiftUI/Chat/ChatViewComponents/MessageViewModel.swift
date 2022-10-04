//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageViewModel: ObservableObject, Hashable {
    static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
        true
    }

    private let id: String = ""

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
