//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import SwiftUI

struct TypingParticipantsView: View {
    @StateObject var viewModel: TypingParticipantsViewModel

    private enum Constants {
        static let padding: CGFloat = 20.0
        static let sectionHeight: CGFloat = 10.0
        static let avatarWidth: CGFloat = 16.0
        static let maxAvatarShown: Int = 3
    }

    var body: some View {
        Group {
            if viewModel.shouldShowIndicator {
                Spacer()
                HStack {
                    // Vstack to make sure AvatarGroup stays in vertical center
                    VStack(spacing: 0) {
                        Spacer()
                        TypingParticipantAvatarGroupContainer(participantList: viewModel.participants)
                            .frame(width: CGFloat(min(Constants.maxAvatarShown,
                                                      viewModel.participants.count)) * Constants.avatarWidth,
                                   alignment: .leading)
                        Spacer()
                    }
                    Text(viewModel.typingIndicatorLabel ?? "")
                        .font(.caption)
                    Spacer()
                }
                // give an explicit frame to constraint avatargroup layout
                .frame(width: UIScreen.main.bounds.size.width,
                       height: Constants.sectionHeight)
                .padding(.leading, Constants.padding)
                Spacer()
            }
        }
    }
}
