//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CaptionsInfoCellView: View {
    var caption: CallCompositeCaptionsData

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(caption.speakerName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(caption.spokenText)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}
