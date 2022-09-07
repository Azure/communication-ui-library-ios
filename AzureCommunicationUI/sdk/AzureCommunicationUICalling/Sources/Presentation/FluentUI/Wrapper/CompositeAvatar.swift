//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeAvatar: View {
    @Binding var displayName: String?
    @Binding var avatarImage: UIImage?
    var isSpeaking: Bool
    var avatarSize: MSFAvatarSize = .xxlarge
    var body: some View {
        let isNameEmpty = displayName == nil
        || displayName?.trimmingCharacters(in: .whitespaces).isEmpty == true
        return Avatar(style: isNameEmpty ? .outlined : .default,
                      size: avatarSize,
                      image: avatarImage,
                      primaryText: displayName)
            .ringColor(StyleProvider.color.primaryColor)
            .isRingVisible(isSpeaking)
            .accessibilityHidden(true)
    }
}
