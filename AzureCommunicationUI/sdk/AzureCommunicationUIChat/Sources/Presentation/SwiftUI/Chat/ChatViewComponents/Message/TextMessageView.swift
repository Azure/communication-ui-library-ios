//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct TextMessageView: View {
    private enum Constants {
        static let localLeadingPadding: CGFloat = 60
        static let remoteAvatarLeadingPadding: CGFloat = 6
        static let remoteLeadingPadding: CGFloat = 30
        static let spacing: CGFloat = 4

        static let contentHorizontalPadding: CGFloat = 10
        static let contentVerticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 5
    }

    let messageModel: ChatMessageInfoModel
    let showUsername: Bool
    let showTime: Bool

    var body: some View {
        HStack(spacing: Constants.spacing) {
            if messageModel.isLocalUser {
                Spacer()
            }
            avatar
            bubble
            if !messageModel.isLocalUser {
                Spacer()
            }
        }
        .padding(.leading, getLeadingPadding)
    }

    var avatar: some View {
        VStack() {
            if showUsername {
                Avatar(style: .outlinedPrimary, size: .size24, primaryText: messageModel.senderDisplayName)
                Spacer()
            }
        }
    }

    var bubble: some View {
        VStack(alignment: .leading) {
            HStack {
                name
                timeStamp
                edited
            }
            Text(messageModel.getContentLabel())
                .font(.body)
        }
        .padding([.leading, .trailing], Constants.contentHorizontalPadding)
        .padding([.top, .bottom], Constants.contentVerticalPadding)
        .background(getMessageBubbleBackground(messageModel: messageModel))
        .cornerRadius(Constants.cornerRadius)
    }

    var name: some View {
        Group {
            if showUsername && messageModel.senderDisplayName != nil {
                Text(messageModel.senderDisplayName!)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(StyleProvider.color.textPrimary))
            }
        }
    }

    var timeStamp: some View {
        Group {
            if showTime {
                Text(messageModel.timestamp)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }

    var edited: some View {
        Group {
            if messageModel.editedOn != nil {
                Text("Edited")
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
            }
        }
    }

    private var getLeadingPadding: CGFloat {
        if messageModel.isLocalUser {
            return Constants.localLeadingPadding
        }

        if showUsername {
            return Constants.remoteAvatarLeadingPadding
        } else {
            return Constants.remoteLeadingPadding
        }
    }

    private func getMessageBubbleBackground(messageModel: ChatMessageInfoModel) -> Color {
        guard messageModel.isLocalUser else {
            return Color(StyleProvider.color.surfaceTertiary)
        }

        if messageModel.sendStatus == .failed {
            return Color(StyleProvider.color.dangerPrimary).opacity(0.2)
        } else {
            return Color(StyleProvider.color.primaryColorTint30)
        }
    }
}
