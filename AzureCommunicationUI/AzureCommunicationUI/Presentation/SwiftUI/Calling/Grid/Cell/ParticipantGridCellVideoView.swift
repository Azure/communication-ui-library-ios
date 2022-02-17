//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantGridCellVideoView: View {
    let rendererView: UIView
    @Binding var isSpeaking: Bool
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    let borderColor = Color(StyleProvider.color.primaryColor)
    var isTitleViewEmpty: Bool {
        return !isMuted && displayName?.trimmingCharacters(in: .whitespaces).isEmpty == true
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 0) {
                VideoRendererView(rendererView: rendererView)
            }

            ParticipantTitleView(displayName: $displayName,
                                 isMuted: $isMuted,
                                 titleFont: Fonts.caption1.font,
                                 mutedIconSize: 14)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(isTitleViewEmpty ? .clear : Color(StyleProvider.color.overlay))
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .padding(.leading, 4)
                .padding(.bottom, screenSizeClass == .iphoneLandscapeScreenSize
                    && UIDevice.current.hasHomeBar ? 16 : 4)

        }.overlay(
            isSpeaking && !isMuted ? RoundedRectangle(cornerRadius: 4).strokeBorder(borderColor, lineWidth: 4) : nil
        ).animation(.default)
    }

}
