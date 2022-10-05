//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
            TopBarView(viewModel: viewModel.topBarViewModel)
            Divider()
            Spacer()
            ThreadView(viewModel: viewModel.threadViewModel)
            messageInput
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

// struct ChatView_Previews: PreviewProvider {
//    static var previews: some View {
//        let compositeViewModelFactory
//    let viewModel = ChatViewModel(
//        ChatView(viewModel: <#T##ChatViewModel#>)
//    }
// }
