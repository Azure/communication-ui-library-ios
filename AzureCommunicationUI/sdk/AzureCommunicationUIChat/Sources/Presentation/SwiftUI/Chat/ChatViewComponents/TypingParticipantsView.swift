//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct TypingParticipantsView: View {
    @ObservedObject var viewModel: TypingParticipantsViewModel

    var body: some View {
        HStack {
            Text(viewModel.typingParticipants ?? "")
                .fontWeight(.light)
        }
    }
}
