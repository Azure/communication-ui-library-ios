//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
//            TopBarView(viewModel: viewModel.topBarViewModel)
            Divider()
            Spacer()
            MessageListView(viewModel: viewModel.messageListViewModel)
            TypingParticipantsView(viewModel: viewModel.typingParticipantsViewModel)
            BottomBarView(viewModel: viewModel.bottomBarViewModel)
        }
        .onAppear {
            viewModel.getInitialMessages()
        }
    }
}
