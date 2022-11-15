//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct TextMessageView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 8
        static let cornerRadius: CGFloat = 5
        static let readReceiptIconSize: CGFloat = 12
        static let readReceiptViewPadding: CGFloat = 3
    }

    @StateObject var viewModel: TextMessageViewModel

    var body: some View {
        HStack(spacing: Constants.readReceiptViewPadding) {
            if viewModel.isLocalUser {
                Spacer()
            }
            bubble
            messageSendStatus
            if !viewModel.isLocalUser {
                Spacer()
            }
        }
    }

    var bubble: some View {
        VStack(alignment: .leading) {
            HStack {
                name
                timeStamp
            }
            Text(viewModel.message.content ?? "No Content") // Handle nil?
                .font(.body)
        }
        .padding([.leading, .trailing], Constants.horizontalPadding)
        .padding([.top, .bottom], Constants.verticalPadding)
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

    var messageSendStatus: some View {
        return Group {
            if viewModel.isLocalUser {
                VStack {
                    Spacer()
                    if let iconName = viewModel.getMessageSendStatusIconName() {
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
        }
    }
}
