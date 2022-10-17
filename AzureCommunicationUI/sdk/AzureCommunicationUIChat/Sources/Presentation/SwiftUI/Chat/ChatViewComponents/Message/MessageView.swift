//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct MessageView: View {
    @StateObject var viewModel: MessageViewModel

    var body: some View {
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
