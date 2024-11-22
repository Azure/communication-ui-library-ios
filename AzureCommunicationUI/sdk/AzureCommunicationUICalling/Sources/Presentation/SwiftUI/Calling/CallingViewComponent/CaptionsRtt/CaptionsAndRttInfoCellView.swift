//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CaptionsAndRttInfoCellView: View {
    var avatarViewManager: AvatarViewManagerProtocol
    var caption: CallCompositeRttCaptionsDisplayData
    @State private var avatarImage: UIImage?
    @State private var displayName: String?
    @State private var isRTL = false
    private let localizationProvider: LocalizationProviderProtocol

    init(caption: CallCompositeRttCaptionsDisplayData,
         avatarViewManager: AvatarViewManagerProtocol,
         localizationProvider: LocalizationProviderProtocol
    ) {
        self.caption = caption
        self.avatarViewManager = avatarViewManager
        self.displayName = caption.displayName
        self.localizationProvider = localizationProvider
    }

    var body: some View {
        HStack(alignment: .top) {
            // Left-side blue indicator spanning the whole cell height
            if !caption.isFinal {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(StyleProvider.color.primaryColorTint20))
                    .frame(width: 4)
            }

            avatarView

            VStack(alignment: isRTL ? .trailing : .leading, spacing: 4) {
                // Display Name and Typing Logo on the same line
                HStack(spacing: 8) {
                    Text(caption.displayName)
                        .font(.caption)
                        .foregroundColor(Color(StyleProvider.color.textSecondary))
                        .lineLimit(1)

                    if !caption.isFinal {
                        Text(localizationProvider.getLocalizedString(.rttTyping))
                            .font(.caption2)
                            .foregroundColor(Color(StyleProvider.color.textSecondary))
                            .padding(.horizontal, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(StyleProvider.color.surface))
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Display Text on the next line
                Text(displayText)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(isRTL ? .trailing : .leading)
                    .lineLimit(nil) // Wrap text to multiple lines
                    .fixedSize(horizontal: false, vertical: true)
                    .environment(\.locale, Locale(identifier: language))
            }
            .frame(maxWidth: .infinity, alignment: isRTL ? .trailing : .leading)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.vertical, 4) // Add padding for vertical spacing
        .background(Color(StyleProvider.color.drawerColor))
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
    }

    // Display text based on caption availability
    private var displayText: String {
        if caption.captionsRttType == .rtt {
            return caption.text
        } else {
            return (caption.captionsText?.isEmpty ?? true) ? caption.spokenText : caption.captionsText ?? ""
        }
    }

    private var language: String {
        (caption.captionsText?.isEmpty ?? true) ? caption.spokenLanguage : caption.captionsLanguage ?? ""
    }
    private func updateAvatar() {
        // Attempt to get the avatar image directly from the avatar storage for the given speaker's ID.
        if let participantViewDataAvatar = avatarViewManager.avatarStorage.value(
            forKey: caption.displayRawId)?.avatarImage {
            // If an avatar image exists, set it.
            avatarImage = participantViewDataAvatar
        } else {
            avatarImage = nil
            displayName = caption.displayName
        }
    }

    private func determineTextDirection() {
        let activeLanguageCode = (caption.captionsLanguage?.isEmpty ?? true) ?
        caption.spokenLanguage : caption.captionsLanguage ?? caption.spokenLanguage
        isRTL = isRightToLeftLanguage(activeLanguageCode)
    }

    // Function to determine if the language is right-to-left
    private func isRightToLeftLanguage(_ languageCode: String) -> Bool {
        let rtlLanguages = ["ar", "he", "fa", "ur"] // Add more as needed
        let locale = Locale(identifier: languageCode)
        return rtlLanguages.contains(locale.languageCode ?? "")
    }
}
