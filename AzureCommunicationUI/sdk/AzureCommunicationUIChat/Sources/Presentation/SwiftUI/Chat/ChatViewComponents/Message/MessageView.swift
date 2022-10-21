//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    @StateObject var viewModel: MessageViewModel

    var body: some View {
        VStack {
            dateHeader
            message
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
}
