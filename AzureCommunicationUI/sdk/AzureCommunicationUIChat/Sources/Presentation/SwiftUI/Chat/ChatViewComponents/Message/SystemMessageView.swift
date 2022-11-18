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

    @StateObject var viewModel: SystemMessageViewModel

    var body: some View {
        HStack(spacing: Constants.spacing) {
            icon
            Text(viewModel.content)
                .font(.caption2)
                .foregroundColor(Color(StyleProvider.color.textSecondary))
            Spacer()
        }
        .padding(.leading, viewModel.icon != nil ? Constants.iconLeadingPadding : Constants.leadingPadding)
    }

    var icon: some View {
        Group {
            if let icon = viewModel.icon {
                Icon(name: icon, size: Constants.iconSize)
            }
        }
    }
}
