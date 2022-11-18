//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@available(iOS 15.0, *)
struct BottomBarView: View {
    private enum Constants {
        static let minimumHeight: CGFloat = 50
        static let focusDelay: CGFloat = 1.0
        static let padding: CGFloat = 12
    }

    @FocusState private var hasFocus: Bool

    @StateObject var viewModel: BottomBarViewModel

    var body: some View {
        HStack(spacing: Constants.padding) {
          Group {
            if viewModel.isLocalUserRemoved {
                localParticipantRemovedBanner
            } else {
                messageTextField
                sendButton
            }
          }
        }
        .frame(minHeight: Constants.minimumHeight)
        .padding([.leading, .trailing], Constants.padding)
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

    var localParticipantRemovedBanner: some View {
        Text("You're no longer a participant")
            .foregroundColor(Color(StyleProvider.color.textSecondary))
    }
}
