//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct TextMessageView: View {
    private enum Constants {
        static let localLeadingPadding: CGFloat = 60
        static let localTrailingPadding: CGFloat = 15
        static let remoteAvatarLeadingPadding: CGFloat = 6
        static let remoteLeadingPadding: CGFloat = 30
        static let remoteTrailingPadding: CGFloat = 44
        static let spacing: CGFloat = 4

        static let contentHorizontalPadding: CGFloat = 10
        static let contentVerticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 5
        static let messageSendStatusIconSize: CGFloat = 12
        static let messageSendStatusViewPadding: CGFloat = 3
    }

    @StateObject var viewModel: TextMessageViewModel

    var body: some View {
        HStack(spacing: Constants.spacing) {
            if viewModel.isLocalUser {
                Spacer()
            }
            avatar
            bubble
            messageSendStatus
            if !viewModel.isLocalUser {
                Spacer()
            }
        }
        .padding(.leading, getLeadingPadding)
        .padding(.trailing, getTrailingPadding)
    }

    var avatar: some View {
        VStack() {
            if viewModel.showUsername {
                Avatar(style: .outlinedPrimary, size: .small, primaryText: viewModel.message.senderDisplayName)
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
            Text(viewModel.message.content ?? "No Content") // Handle nil?
                .font(.body)
        }
        .padding([.leading, .trailing], Constants.contentHorizontalPadding)
        .padding([.top, .bottom], Constants.contentVerticalPadding)
        .background(viewModel.isLocalUser
                    ? Color(StyleProvider.color.primaryColorTint30)
                    : Color(StyleProvider.color.surfaceTertiary))
        .cornerRadius(Constants.cornerRadius)
    }

    var name: some View {
        Group {
            if viewModel.showUsername && viewModel.message.senderDisplayName != nil {
                Text(viewModel.message.senderDisplayName!)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }

    var timeStamp: some View {
        Group {
            if viewModel.showTime {
                Text(viewModel.message.createdOn.value, style: .time)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
            }
        }
    }

    var edited: some View {
        Group {
            if viewModel.message.editedOn != nil {
                Text("Edited")
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
            }
        }
    }

    var messageSendStatus: some View {
        let tintColor = viewModel.message.sendStatus == .failed
                            ? StyleProvider.color.dangerPrimary : StyleProvider.color.primaryColor
        return Group {
            if viewModel.isLocalUser {
                VStack {
                    Spacer()
                    if let iconName = viewModel.getMessageSendStatusIconName() {
                        StyleProvider.icon.getImage(for: iconName)
                            .frame(width: Constants.messageSendStatusIconSize,
                                   height: Constants.messageSendStatusIconSize)
                            .foregroundColor(Color(tintColor))
                            .padding(.bottom, Constants.messageSendStatusViewPadding)
                    }
                }
            }
        }
    }

    private var getLeadingPadding: CGFloat {
        if viewModel.isLocalUser {
            return Constants.localLeadingPadding
        }

        if viewModel.showUsername {
            return Constants.remoteAvatarLeadingPadding
        } else {
            return Constants.remoteLeadingPadding
        }
    }

    private var getTrailingPadding: CGFloat {
        if !viewModel.isLocalUser {
            return Constants.remoteTrailingPadding
        }

        if viewModel.showMessageSendStatusIcon {
            return Constants.messageSendStatusViewPadding
        } else {
            return Constants.localTrailingPadding
        }
    }
}
