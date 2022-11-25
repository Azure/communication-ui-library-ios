//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct TextMessageView: View {
    private enum Constants {
        static let localLeadingPadding: CGFloat = 60
        static let localTrailingPadding: CGFloat = 10
        static let remoteAvatarLeadingPadding: CGFloat = 6
        static let remoteLeadingPadding: CGFloat = 30
        static let remoteTrailingPadding: CGFloat = 31
        static let spacing: CGFloat = 4

        static let contentHorizontalPadding: CGFloat = 10
        static let contentVerticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 5
        static let readReceiptIconSize: CGFloat = 12
        static let readReceiptViewPadding: CGFloat = 3
    }

    let message: ChatMessageInfoModel
    let showUsername: Bool
    let showTime: Bool

    var body: some View {
        HStack(spacing: Constants.spacing) {
            if message.isLocalUser {
                Spacer()
            }
            avatar
            bubble
            messageSendStatus
            if !message.isLocalUser {
                Spacer()
            }
        }
        .padding(.leading, getLeadingPadding)
        .padding(.trailing, message.isLocalUser ? Constants.localTrailingPadding : Constants.remoteTrailingPadding)
    }

    var avatar: some View {
        VStack() {
            if showUsername {
                Avatar(style: .outlinedPrimary, size: .small, primaryText: message.senderDisplayName)
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
            Text(message.getContentLabel())
                .font(.body)
        }
        .padding([.leading, .trailing], Constants.contentHorizontalPadding)
        .padding([.top, .bottom], Constants.contentVerticalPadding)
        .background(message.isLocalUser
                    ? Color(StyleProvider.color.primaryColorTint30)
                    : Color(StyleProvider.color.surfaceTertiary))
        .cornerRadius(Constants.cornerRadius)
    }

    var name: some View {
        Group {
            if showUsername && message.senderDisplayName != nil {
                Text(message.senderDisplayName!)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(StyleProvider.color.textPrimary))
            }
        }
    }

    var timeStamp: some View {
        Group {
            if showTime {
                Text(message.timestamp)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }

    var edited: some View {
        Group {
            if message.editedOn != nil {
                Text("Edited")
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
            }
        }
    }

    var messageSendStatus: some View {
        VStack {
            Spacer()
            if let iconName = message.getIconNameForMessageSendStatus() {
                StyleProvider.icon.getImage(for: iconName)
                    .frame(width: Constants.readReceiptIconSize,
                           height: Constants.readReceiptIconSize)
                    .foregroundColor(Color(StyleProvider.color.primaryColor))
                    .padding(.bottom, Constants.readReceiptViewPadding)
            } else {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: Constants.readReceiptIconSize,
                           height: Constants.readReceiptIconSize)
            }
        }
    }

    private var getLeadingPadding: CGFloat {
        if message.isLocalUser {
            return Constants.localLeadingPadding
        }

        if showUsername {
            return Constants.remoteAvatarLeadingPadding
        } else {
            return Constants.remoteLeadingPadding
        }
    }
}
