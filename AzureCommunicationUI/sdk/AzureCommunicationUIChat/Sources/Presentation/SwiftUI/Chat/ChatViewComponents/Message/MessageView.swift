//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 0
        static let topPadding: CGFloat = 8
        static let topConsecutivePadding: CGFloat = 4
        static let remoteTrailingPadding: CGFloat = 60
        static let messageWithSendStatusTrailingPadding: CGFloat = 1
    }

    let messageModel: ChatMessageInfoModel
    let showDateHeader: Bool
    let isConsecutive: Bool
    let showUsername: Bool
    let showTime: Bool
    let showMessageStatus: Bool

    // Inject localization with environment?

    var body: some View {
        let edgeInsets = EdgeInsets(top: isConsecutive
                                        ? Constants.topConsecutivePadding
                                        : Constants.topPadding,
                                    leading: Constants.horizontalPadding,
                                    bottom: Constants.bottomPadding,
                                    trailing: getMessageTrailingPadding(for: messageModel))
        VStack {
            dateHeader
            message
            .padding(edgeInsets)
        }
    }

    var dateHeader: some View {
        Group {
            if showDateHeader {
                Text(messageModel.dateHeaderLabel)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }

    var message: some View {
        Group {
            switch messageModel.type {
            case .text, .html:
                if messageModel.deletedOn == nil || messageModel.content == nil {
                    TextMessageView(messageModel: messageModel,
                                    showUsername: showUsername,
                                    showTime: showTime)
                }
            case .participantsAdded, .participantsRemoved, .topicUpdated:
                SystemMessageView(messageModel: messageModel)
            default:
                EmptyView()
            }
        }
    }

    private func getMessageTrailingPadding(for message: ChatMessageInfoModel) -> CGFloat {
        if !message.isLocalUser {
            return Constants.remoteTrailingPadding
        }
        if message.type == .text,
           showMessageStatus,
           message.sendStatus != nil {
            return Constants.messageWithSendStatusTrailingPadding
        }
        return Constants.horizontalPadding
    }
}
