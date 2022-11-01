//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@available(iOS 15.0, *)
struct BottomBarView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 0
    }

    @FocusState private var hasFocus: Bool

    @StateObject var viewModel: BottomBarViewModel

    var body: some View {
        HStack {
            messageTextField
            sendButton
        }
        .padding([.leading, .trailing], Constants.horizontalPadding)
        .padding([.top, .bottom], Constants.verticalPadding)
    }

    var messageTextField: some View {
        TextField("Message...",
                  text: $viewModel.message,
                  onCommit: viewModel.sendMessage)
        .submitLabel(.send)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .focused($hasFocus)
        .onChange(of: viewModel.hasFocus) {
            hasFocus = $0
        }
        .onChange(of: hasFocus) {
            viewModel.hasFocus = $0
        }
        .onChange(of: viewModel.message) { newValue in
            guard !newValue.isEmpty else {
                return
            }
            viewModel.sendTypingIndicator()
        }
        .onAppear {
           viewModel.hasFocus = true
        }
    }

    var sendButton: some View {
        IconButton(viewModel: viewModel.sendButtonViewModel)
            .flipsForRightToLeftLayoutDirection(true)
    }
}
