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
        VStack(alignment: isRTL ? .trailing : .leading, spacing: 0) {
            HStack {
                avatarView
                Text(caption.speakerName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(displayText)
                .font(.callout)
                .foregroundColor(.primary)
                .multilineTextAlignment(isRTL ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
        .padding(.horizontal)
        .onAppear {
            updateAvatar()
            determineTextDirection()
        }
    }

    private var avatarView: some View {
        CompositeAvatar(displayName: $displayName,
                        avatarImage: $avatarImage,
                        isSpeaking: false,
                        avatarSize: .size32)
    }

    // Display text based on caption availability
    private var displayText: String {
        (caption.captionText?.isEmpty ?? true) ? caption.spokenText : caption.captionText ?? ""
    }

    private func updateAvatar() {
        if let participantViewData = avatarViewManager.avatarStorage.value(forKey: caption.speakerRawId) {
            avatarImage = participantViewData.avatarImage
        } else {
            avatarImage = nil
            displayName = caption.speakerName
        }
    }

    private func determineTextDirection() {
        let activeLanguageCode = (caption.captionText?.isEmpty ?? true) ?
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
