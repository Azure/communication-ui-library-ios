//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@available(iOS 15, *)
struct ThreadView: View {
    @ObservedObject var viewModel: ThreadViewModel

    @State private var now = Date()

    var body: some View {
        ScrollViewReader { value in
            List {
                ForEach(Array(viewModel.chatMessages.enumerated()), id: \.element) { index, message in
                    HStack {
                        MessageView(viewModel: viewModel.makeMessageViewModel(message: message, index: index))
                        if viewModel.isMessageRead(message: message, index: index) {
                            Text("Read")
                        }
                    }
                    .id(index)
                    .listRowSeparator(.hidden)
                }
                .onChange(of: viewModel.chatMessages.count) { _ in
                    value.scrollTo(viewModel.chatMessages.count - 1)
                }
            }
            .listStyle(.plain)
            .refreshable {
                now = Date()
                viewModel.getPreviousMessages()
            }
        }
    }
}

struct LegacyThreadView: View {
    @ObservedObject var viewModel: ThreadViewModel

    @State private var now = Date()

    var body: some View {
        RefreshableScrollView(onRefresh: { done in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.now = Date()
                viewModel.getPreviousMessages()
                done()
            }
        }, content: {
            ScrollViewReader { value in
                LazyVStack {
                    ForEach(Array(viewModel.chatMessages.enumerated()), id: \.element) { index, message in
                        HStack {
                            MessageView(viewModel: viewModel.makeMessageViewModel(message: message, index: index))
                            if viewModel.isMessageRead(message: message, index: index) {
                                Text("Read")
                            }
                        }
                    }
                    .onChange(of: viewModel.chatMessages.count) { _ in
                        value.scrollTo(viewModel.chatMessages.count - 1)
                    }
                }
            }
        })
    }
}
