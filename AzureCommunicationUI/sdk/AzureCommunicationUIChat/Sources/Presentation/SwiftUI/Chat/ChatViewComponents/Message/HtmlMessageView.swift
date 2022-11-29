//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct HtmlMessageView: View {
    let message: ChatMessageInfoModel

    var body: some View {
        HStack {
            Text(message.getContentLabel())
                .font(.caption2)
                .foregroundColor(Color(StyleProvider.color.textSecondary))
            Spacer()
        }
    }
}
