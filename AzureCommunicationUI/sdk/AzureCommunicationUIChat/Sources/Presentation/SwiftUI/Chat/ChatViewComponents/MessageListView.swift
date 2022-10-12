//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageListView: View {
    @StateObject var viewModel: MessageListViewModel

    var body: some View {
        if #available(iOS 15, *) {
            messageList
        } else {
            legacyMessageList
        }
    }

    @available(iOS 15.0, *)
    var messageList: some View {
        ScrollViewReader { value in
            List {
                ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, message in
                    MessageView(viewModel: message)
                    .id(index)
                    .listRowSeparator(.hidden)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    value.scrollTo(viewModel.messages.count - 1)
                }
            }
            .listStyle(.plain)
        }
    }

    // iOS 14
    var legacyMessageList: some View {
        ScrollViewReader { value in
            LazyVStack {
                ForEach(Array(viewModel.messages.enumerated()), id: \.element) { index, message in
                    HStack {
                        MessageView(viewModel: message)
                        .id(index)
                    }
                }
                .onChange(of: viewModel.messages.count) { _ in
                    value.scrollTo(viewModel.messages.count - 1)
                }
            }
        }
    }
}
