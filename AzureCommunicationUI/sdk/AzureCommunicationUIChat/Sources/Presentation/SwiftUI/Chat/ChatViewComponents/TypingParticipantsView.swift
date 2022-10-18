//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct TypingParticipantsView: View {
    @ObservedObject var viewModel: TypingParticipantsViewModel

    private enum Constants {
        static let padding: CGFloat = 20.0
        static let sectionHeight: CGFloat = 10.0
        static let avatarWidth: CGFloat = 16.0
    }

    var body: some View {
        Spacer()
        HStack {
            VStack(spacing: 0) {
                Spacer()
                TypingParticipantAvatarGroupContainer(participantList: viewModel.participants)
                    .frame(width: CGFloat(viewModel.participants.count) * Constants.avatarWidth,
                           alignment: .leading)
                Spacer()
            }
            Text(viewModel.typingParticipants)
                .fontWeight(.light)
            Spacer()
        }
        .frame(width: UIScreen.main.bounds.size.width,
               height: Constants.sectionHeight)
        .padding(.leading, Constants.padding)
        Spacer()
    }
}
