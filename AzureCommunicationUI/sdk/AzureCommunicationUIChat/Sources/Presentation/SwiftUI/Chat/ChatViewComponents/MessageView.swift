//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    let viewModel: MessageViewModel

    var body: some View {
        BubbleMessageView(message: "Hello World",
                          createdOn: Date(),
                          displayName: "John Smith",
                          isSelf: true)
    }
}
