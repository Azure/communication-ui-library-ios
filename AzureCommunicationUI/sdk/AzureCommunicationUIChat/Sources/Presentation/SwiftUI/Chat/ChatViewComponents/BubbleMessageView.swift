//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BubbleMessageView: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 5
    }

    let message: String
    let createdOn: Date?
    let displayName: String?
    let isSelf: Bool
    let isRead: Bool = false

    var body: some View {
        HStack {
            if isSelf {
                Spacer()
            }
            bubble
            readReceipt
            if !isSelf {
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
            Text(message)
                .font(.body)
        }
        .padding()
        .background(isSelf
                    ? Color(StyleProvider.color.primaryColorTint30)
                    : Color(StyleProvider.color.surfaceTertiary))
        .cornerRadius(Constants.cornerRadius)
    }

    var name: some View {
        Group {
            if !isSelf && displayName != nil {
                Text(displayName!)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }
    var timeStamp: some View {
        Group {
            if createdOn != nil {
                Text(createdOn!, style: .time)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textDisabled))
            }
        }
    }
    var readReceipt: some View {
        Group {
            if isRead {
                // Replace with icon
                Text("Read")
            }
        }
    }
}
