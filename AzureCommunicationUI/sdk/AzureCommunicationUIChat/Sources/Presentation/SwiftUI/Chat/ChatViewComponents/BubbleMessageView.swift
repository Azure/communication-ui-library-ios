//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct BubbleMessageView: View {
    let padding: CGFloat = 10
    let cornerRadius: CGFloat = 10

    let message: String
    let createdOn: Date?
    let displayName: String?
    let isSelf: Bool
    let isRead: Bool = false

    var body: some View {
        HStack {
            if isSelf {
                Spacer()
            }
            VStack(alignment: .leading) {
                HStack {
                    name
                    timeStamp
                }
                .foregroundColor(isSelf ? Color.grey500 : Color.grey150)
                Text(message)
                    .foregroundColor(Color.black)
                    .font(.body)
            }
            .padding(padding)
            .background(isSelf ? Color.commBlueTint30 : Color.grey50)
            .cornerRadius(cornerRadius)
            readReceipt
            if !isSelf {
                Spacer()
            }
        }
    }

    var name: some View {
        Group {
            if !isSelf && displayName != nil {
                Text(displayName!)
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
    var timeStamp: some View {
        Group {
            if createdOn != nil {
                Text(createdOn!, style: .time)
                    .font(.caption)
            }
        }
    }
    var readReceipt: some View {
        Group {
            if isRead {
                Text("Read")
            }
        }
    }
}
