//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ChatView: View {
    private enum Constants {
        static let messageListBottomPadding: CGFloat = 12
        static let typingParticipantsBottomPadding: CGFloat = 12
    }

    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            MessageListView(viewModel: viewModel.messageListViewModel)
                .padding(.bottom, Constants.messageListBottomPadding )
            TypingParticipantsView(viewModel: viewModel.typingParticipantsViewModel)
                .padding(.bottom, Constants.typingParticipantsBottomPadding)
            BottomBarView(viewModel: viewModel.bottomBarViewModel)
                .padding(.bottom)
        }
        .onAppear {
            viewModel.getInitialMessages()
        }
    }
}
