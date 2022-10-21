//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SystemMessageView: View {
    @StateObject var viewModel: SystemMessageViewModel

    var body: some View {
        HStack {
            Text(viewModel.content)
                .font(.caption2)
                .foregroundColor(Color(StyleProvider.color.textSecondary))
            Spacer()
        }
    }
}
