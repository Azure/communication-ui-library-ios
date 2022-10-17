//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            TopBarView(viewModel: viewModel.topBarViewModel)
            Divider()
            Spacer()
            ThreadView(viewModel: viewModel.threadViewModel)
            TypingParticipantsView(viewModel: viewModel.typingParticipantsViewModel)
            Divider()
            messageInput
        }
        .onAppear {
            viewModel.getInitialMessages()
        }
    }

    var messageInput: some View {
        Group {
            if #available(iOS 15, *) {
                MessageInputView(viewModel: viewModel.messageInputViewModel)
            } else {
                // Use Custom legacy textfeld to handle focusing on iOS 14
            }
        }
    }
}
