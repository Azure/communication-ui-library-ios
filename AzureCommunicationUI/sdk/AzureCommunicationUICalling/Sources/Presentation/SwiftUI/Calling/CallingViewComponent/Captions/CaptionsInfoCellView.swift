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
    @State private var isRTL = false

    init(caption: CallCompositeCaptionsData, avatarViewManager: AvatarViewManagerProtocol) {
        self.caption = caption
        self.avatarViewManager = avatarViewManager
        self.displayName = caption.speakerName
    }

    var body: some View {
        HStack(alignment: .top) {
            avatarView
            VStack(alignment: isRTL ? .trailing : .leading, spacing: 0) {
                Text(caption.speakerName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(caption.spokenText)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(isRTL ? .trailing : .leading)
            }.frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .background(Color(StyleProvider.color.backgroundColor))
        .onAppear {
            updateAvatar()
            determineTextDirection()
        }
    }

    private var avatarView: some View {
        CompositeAvatar(displayName: $displayName,
                        avatarImage: $avatarImage,
                        isSpeaking: false,
                        avatarSize: .size24)
        .frame(width: 30, height: 30)
    }

    // Display text based on caption availability
    private var displayText: String {
        (caption.captionText?.isEmpty ?? true) ? caption.spokenText : caption.captionText ?? ""
    }

    private func updateAvatar() {
        // Attempt to get the avatar image directly from the avatar storage for the given speaker's ID.
        if let participantViewDataAvatar = avatarViewManager.avatarStorage.value(
            forKey: caption.speakerRawId)?.avatarImage {
            // If an avatar image exists, set it.
            avatarImage = participantViewDataAvatar
        } else {
            avatarImage = nil
            displayName = caption.speakerName
        }
    }

    private func determineTextDirection() {
        let activeLanguageCode = (caption.captionLanguage?.isEmpty ?? true) ?
        caption.spokenLanguage : caption.captionLanguage ?? caption.spokenLanguage
        isRTL = isRightToLeftLanguage(activeLanguageCode)
    }

    // Function to determine if the language is right-to-left
    private func isRightToLeftLanguage(_ languageCode: String) -> Bool {
        let rtlLanguages = ["ar", "he", "fa", "ur"] // Add more as needed
        let locale = Locale(identifier: languageCode)
        return rtlLanguages.contains(locale.languageCode ?? "")
    }
}
