//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        Text("Hello, World! ChatView")
            .onAppear {
                viewModel.getInitialMessages()
            }
        Text("Message Count: \(viewModel.chatMessages.count)")
    }
}
