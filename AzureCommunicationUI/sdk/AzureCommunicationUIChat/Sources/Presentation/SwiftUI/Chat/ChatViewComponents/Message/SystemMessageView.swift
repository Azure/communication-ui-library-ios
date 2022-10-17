//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SystemMessageView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption2)
            .foregroundColor(Color(StyleProvider.color.textSecondary))
    }
}
