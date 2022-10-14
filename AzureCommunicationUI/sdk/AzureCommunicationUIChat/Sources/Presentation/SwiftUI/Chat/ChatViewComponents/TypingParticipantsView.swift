//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct TypingParticipantsView: View {
    @ObservedObject var viewModel: TypingParticipantsViewModel

    var body: some View {
        HStack {
            /* participantAvatars */
            Text(viewModel.typingParticipants)
                .fontWeight(.light)
        }
    }

    /*
    var participantAvatars: some View {
        // To be added
    }*/
}
