//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

@available(iOS 15, *)
struct MessageInputView: View {
    @ObservedObject var viewModel: MessageInputViewModel

    @State private var message: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            messageTextField
            sendButton
        }
        .frame(minHeight: CGFloat(50))
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isFocused = true
            }
        }
    }

    var messageTextField: some View {
        TextField("Message...", text: $message) {
            sendMessage()
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .focused($isFocused)
        .onChange(of: message) { newValue in
            if !newValue.isEmpty {
                viewModel.sendTypingIndicator()
            }
        }
    }
    var sendButton: some View {
        Button(action: sendMessage) {
            Text("Send")
        }
    }

    private func sendMessage() {
        isFocused = true
        guard !message.isEmpty else {
            return
        }
        viewModel.sendMessage(content: message)
        message = ""
    }
}
