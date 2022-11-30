//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SystemMessageView: View {
    private enum Constants {
        static let leadingPadding: CGFloat = 34
        static let iconLeadingPadding: CGFloat = 14
        static let spacing: CGFloat = 4
        static let iconSize: CGFloat = 16
    }

    let messageModel: ChatMessageInfoModel

    var body: some View {
        HStack(spacing: Constants.spacing) {
            icon
            message
            Spacer()
        }
        .padding(.leading, messageModel.systemIcon != nil ? Constants.iconLeadingPadding : Constants.leadingPadding)
    }

    var message: some View {
        Text(messageModel.systemLabel)
            .font(.caption2)
            .foregroundColor(Color(StyleProvider.color.textSecondary))
    }

    var icon: some View {
        Group {
            if let icon = messageModel.systemIcon {
                Icon(name: icon, size: Constants.iconSize)
            }
        }
    }
}
