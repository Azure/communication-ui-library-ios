//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import AzureCommunicationCommon
import AzureCommunicationChat
import AzureCore

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    var avatarManager: AvatarViewManager?

    var body: some View {
        VStack {
            titleHeader
            numberOfParticipants
            participants
            Divider()
            messages
            TypingParticipantsView(viewModel: viewModel.typingParticipantsViewModel)
        }
        .onAppear {
            viewModel.startChat()
        }
    }

    var titleHeader: some View {
        HStack {
            ZStack {
                HStack {
                    Button(action: {
                            // hide the keyboard
                            // setting FocusState to false needs more time for animation than UIKit transition
#if canImport(UIKit)
                            UIApplication.shared
                                .sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
#endif
                            viewModel.backButtonTapped()
                    }, label: {
                        Text("Back")
                            .padding()
                    })
                    Spacer()
                }
                HStack {
                    VStack {
                        Text("Chat")
                            .font(.body)
                        Text(String(format: "%d People", viewModel.participants.count))
                            .foregroundColor(Color.grey500)
                            .font(.caption)
                    }
                }
            }
        }
    }

    var numberOfParticipants: some View {
        Text(String(format: "%d People", viewModel.participants.filter {$0.displayName != "admin"}.count))
            .foregroundColor(Color.grey500)
            .font(.caption)
    }

    var participants: some View {
        let participantsList = viewModel.participants
            .map {$0.displayName}
            .filter {$0 != "admin"}
            .joined(separator: ", ")

        return Text(participantsList)
                .foregroundColor(Color.grey500)
                .font(.caption)
    }

    var messages: some View {
        Group {
            if #available(iOS 15, *) {
                ThreadView(viewModel: viewModel.threadViewModel)
                    .padding()
                MessageInputView(viewModel: viewModel.messageInputViewModel)
                    .padding()
            } else {
                LegacyThreadView(viewModel: viewModel.threadViewModel)
                // Use Custom legacy textfeld to handle focusing on iOS 14 and lower
            }
        }
    }
}
