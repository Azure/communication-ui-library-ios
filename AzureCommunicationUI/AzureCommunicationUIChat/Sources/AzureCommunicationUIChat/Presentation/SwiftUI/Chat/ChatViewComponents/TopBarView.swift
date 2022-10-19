//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct TopBarView: View {
    private enum Constants {
        static let horizontalPadding: CGFloat = 10
        static let verticalPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 5
    }

    @StateObject var viewModel: TopBarViewModel

    var body: some View {
        ZStack {
            HStack {
                dismissButton
                Spacer()
            }
            header
        }
        .padding([.leading, .trailing], Constants.horizontalPadding)
        .padding([.top], Constants.verticalPadding)
    }

    var dismissButton: some View {
        IconButton(viewModel: viewModel.dismissButtonViewModel)
            .flipsForRightToLeftLayoutDirection(true)
    }

    var header: some View {
        VStack {
            Text("Chat")
                .font(.body)
            numberOfParticipants
        }
    }

    var numberOfParticipants: some View {
        Text(viewModel.numberOfParticipantsLabel)
            .foregroundColor(Color(StyleProvider.color.textSecondary))
            .font(.caption)
    }
}
