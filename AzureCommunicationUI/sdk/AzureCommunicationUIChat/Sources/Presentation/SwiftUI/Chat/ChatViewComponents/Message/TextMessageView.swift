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
    }

    @StateObject var viewModel: TextMessageViewModel

    var body: some View {
        HStack {
            if viewModel.isLocalUser {
                Spacer()
            }
            bubble
            readReceipt
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
        let isRead = false
        return Group {
            if isRead {
                // Replace with icon
                Text("Read")
            }
        }
    }
}
