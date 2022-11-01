//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    @StateObject var viewModel: MessageViewModel

    private let isDebugOn: Bool = true

    var body: some View {
        VStack {
            dateHeader
            if isDebugOn {
                messageWithDebug
            } else {
                message
            }
        }
    }

    var dateHeader: some View {
        Group {
            if viewModel.showDateHeader {
                Text(viewModel.dateHeaderLabel)
                    .font(.caption)
                    .foregroundColor(Color(StyleProvider.color.textSecondary))
            }
        }
    }

    var message: some View {
        Group {
            switch viewModel {
            case let textMessageViewModel as TextMessageViewModel:
                TextMessageView(viewModel: textMessageViewModel)
            case let systemMessageViewModel as SystemMessageViewModel:
                SystemMessageView(viewModel: systemMessageViewModel)
            default:
                EmptyView()
            }
        }
    }

    var messageWithDebug: some View {
        HStack {
            VStack {
                Text(viewModel.message.id)
                    .font(.caption2)
                Text(viewModel.message.createdOn.requestString)
                    .font(.caption2)
                Text(viewModel.message.senderDisplayName ?? "nil")
                    .font(.caption2)
            }
            message
        }
    }
}
