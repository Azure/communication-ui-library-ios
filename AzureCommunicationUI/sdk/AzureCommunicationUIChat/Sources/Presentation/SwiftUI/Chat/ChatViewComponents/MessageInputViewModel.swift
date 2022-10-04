//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class MessageInputViewModel: ObservableObject {
    @Published var message: String = ""
    @Published var hasFocus: Bool = true

    func sendMessage() {
        hasFocus = true
        guard !message.isEmpty else {
            return
        }
        // Insert send message action
        message = ""
    }
}
