//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct HtmlMessageView: View {
    @StateObject var viewModel: HtmlMessageViewModel

    var body: some View {
        HStack {
            Text(viewModel.message.content ?? "No Content")
                .font(.caption2)
                .foregroundColor(Color(StyleProvider.color.textSecondary))
            Spacer()
        }
    }
}
