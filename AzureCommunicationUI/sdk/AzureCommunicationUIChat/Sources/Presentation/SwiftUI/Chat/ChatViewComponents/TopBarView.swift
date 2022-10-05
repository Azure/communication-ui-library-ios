//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct TopBarView: View {
    @StateObject var viewModel: TopBarViewModel

    var body: some View {
        ZStack {
            HStack {
                backButton
                Spacer()
            }
            header
        }
    }

    var backButton: some View {
        Button(action: {
            // Insert go back action
        }, label: {
            Text("Back")
                .padding()
        })
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
