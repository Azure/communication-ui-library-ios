//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    @StateObject var viewModel: MessageViewModel

    var body: some View {
        TextMessageView(message: "Hello World",
                          createdOn: Date(),
                          displayName: "John Smith",
                          isSelf: true)
        SystemMessageView(message: "System Message")
    }
}
