//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CaptionsInfoCellView: View {
    var avatarViewManager: AvatarViewManagerProtocol
    var caption: CallCompositeCaptionsData
    @State private var avatarImage: UIImage?
    @State private var displayName: String?
    init(caption: CallCompositeCaptionsData, avatarViewManager: AvatarViewManagerProtocol) {
        self.caption = caption
        self.avatarViewManager = avatarViewManager
        self.displayName = caption.speakerName
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                avatarView
                Text(caption.speakerName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(caption.spokenText)
                .font(.callout)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .onAppear {
            updateAvatar()
        }
    }

    private var avatarView: some View {
        CompositeAvatar(displayName: $displayName,
                        avatarImage: $avatarImage,
                        isSpeaking: false,
                        avatarSize: .size24)
    }

    private func updateAvatar() {
        if let participantViewData = avatarViewManager.avatarStorage.value(forKey: caption.speakerRawId) {
            avatarImage = participantViewData.avatarImage
        } else {
            avatarImage = nil  // Reset the avatar if no data is found
            displayName = caption.speakerName
        }
    }
}
