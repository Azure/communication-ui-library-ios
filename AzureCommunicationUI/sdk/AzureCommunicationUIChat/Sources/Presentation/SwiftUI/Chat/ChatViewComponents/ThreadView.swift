//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@available(iOS 15.0, *)
struct ThreadView: View {
    @StateObject var viewModel: ThreadViewModel

    var body: some View {
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
//            .refreshable {
//                now = Date()
//                viewModel.getPreviousMessages()
//            }
        }
    }
}
