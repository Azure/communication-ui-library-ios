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
        static let readReceiptIconWidth: CGFloat = 10
        static let readReceiptIconHeight: CGFloat = 6
        static let readReceiptViewPadding: CGFloat = 3
        static let bubbleBottomPadding: CGFloat = 4
    }

    @StateObject var viewModel: TextMessageViewModel

    var body: some View {
        HStack {
            if viewModel.isLocalUser {
                Spacer()
            }
            bubble
            readReceipt
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

    var readReceipt: some View {
        return Group {
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: Constants.readReceiptIconWidth,
                            height: Constants.readReceiptIconHeight)
//                Text("\(String(viewModel.showReadIcon))")
                if viewModel.showReadIcon {
                    StyleProvider.icon.getImage(for: .readReceipt)
                        .frame(width: Constants.readReceiptIconWidth,
                                height: Constants.readReceiptIconHeight)
                        .padding(.bottom, Constants.readReceiptViewPadding)
                }
            }
        }
    }
}
