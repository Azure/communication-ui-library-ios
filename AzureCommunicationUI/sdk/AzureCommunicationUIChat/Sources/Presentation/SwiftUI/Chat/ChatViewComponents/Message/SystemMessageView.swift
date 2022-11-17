//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SystemMessageView: View {
    private enum Constants {
        static let leadingPadding: CGFloat = 34
        static let iconSize: CGFloat = 24
    }

    @StateObject var viewModel: SystemMessageViewModel

    var body: some View {
        HStack {
            icon
            Text(viewModel.content)
                .font(.caption2)
                .foregroundColor(Color(StyleProvider.color.textSecondary))
                .padding(.leading, Constants.leadingPadding)
            Spacer()
        }
    }

    var icon: some View {
        Icon(name: .systemJoin, size: Constants.iconSize)
    }
}
