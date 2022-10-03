//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel

    var body: some View {
        VStack {
            titleHeader
            Divider()
//            messages
//            TypingParticipantsView(viewModel: viewModel.typingParticipantsViewModel)
        }
        .onAppear {
//            viewModel.startChat()
        }
    }

    var titleHeader: some View {
        ZStack {
            HStack {
                Button(action: {
                    // Go back
                }, label: {
                    Text("Back")
                        .padding()
                })
                Spacer()
            }
            VStack {
                Text("Chat")
                    .font(.body)
                numberOfParticipants
            }
        }
    }

    var numberOfParticipants: some View {
        // Should we filter out admin user in redux/service layer?
        Text(String(format: "%d People", viewModel.participants.filter {$0.displayName != "admin"}.count))
            .foregroundColor(Color(StyleProvider.color.textSecondary))
            .font(.caption)
    }
}
