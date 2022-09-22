//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SystemMessageView: View {
    let padding: CGFloat = 10

//    let icon: String
    let message: String

    var body: some View {
        HStack {
//            Image("Icon")
            Text(message)
                .foregroundColor(Color.black)
                .font(.body)
        }
        .padding(padding)
    }
}
