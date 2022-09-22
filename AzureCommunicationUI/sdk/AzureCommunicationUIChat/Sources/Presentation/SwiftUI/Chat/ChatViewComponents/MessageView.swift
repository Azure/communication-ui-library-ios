//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    let viewModel: MessageViewModel

    var body: some View {
        switch viewModel.message.type {
        case .text, .html, .custom("RichText/Html"):
            textMessageView
        case .participantsAdded:
            participantAddedView
        case .participantsRemoved:
            participantRemovedView
        default:
            SystemMessageView(message: "Unsupported message type")
        }
    }

    var textMessageView: some View {
        VStack(alignment: .center) {
            let isSelf = viewModel.isSelf()
            let isFirstRecentMessage = viewModel.isFirstRecentMessage()
            if isFirstRecentMessage {
                Text("Today at \(viewModel.message.createdOn.value, style: .time)")
                    .font(.caption)
            }
            if !isFirstRecentMessage && viewModel.isConsecutiveMessage() {
                BubbleMessageView(message: viewModel.getContentString(),
                            createdOn: nil,
                            displayName: nil,
                            isSelf: isSelf)
            } else {
                BubbleMessageView(message: viewModel.getContentString(),
                                  createdOn: viewModel.message.createdOn.value,
                                  displayName: viewModel.message.senderDisplayName,
                            isSelf: isSelf)
            }
        }.onAppear {
            viewModel.sendReadReceipt()
        }
    }

    var participantAddedView: some View {
        let participantsMessage = viewModel.message.participants.map {$0.displayName}
            .joined(separator: ", ")
        let joinedMessage = "joined the chat."
        return SystemMessageView(message: "\(participantsMessage) \(joinedMessage)")
    }

    var participantRemovedView: some View {
        let participantsMessage = viewModel.message.participants.map {$0.displayName}
            .joined(separator: ", ")
        let leftMessage = "left the chat."
        return SystemMessageView(message: "\(participantsMessage) \(leftMessage)")
    }
}
