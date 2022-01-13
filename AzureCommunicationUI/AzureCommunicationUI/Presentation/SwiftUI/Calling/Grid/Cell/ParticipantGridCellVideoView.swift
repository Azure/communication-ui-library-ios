//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantGridCellVideoView: View {
    let rendererView: UIView
    let getRendererViewStreamSize: () -> CGSize?
    let zoomable: Bool
    @Binding var isSpeaking: Bool
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType
    @State private var scale: CGFloat = 1.0

    let borderColor = Color(StyleProvider.color.primaryColor)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 0) {
                if zoomable {
                    zoomableVideoRenderView
                } else {
                    videoRenderView
                }
            }

            ParticipantTitleView(displayName: $displayName,
                                 isMuted: $isMuted,
                                 titleFont: Fonts.caption1.font,
                                 mutedIconSize: 14)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(Color(StyleProvider.color.overlay))
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .padding(.leading, 4)
                .padding(.bottom, screenSizeClass == .iphoneLandscapeScreenSize
                    && UIDevice.current.hasHomeBar ? 16 : 4)

        }.overlay(
            isSpeaking && !isMuted ? RoundedRectangle(cornerRadius: 4).strokeBorder(borderColor, lineWidth: 4) : nil
        ).animation(.default)
    }

    var videoRenderView: some View {
        VideoRendererView(rendererView: self.rendererView)
    }

    var zoomableVideoRenderView: some View {
        ZoomableVideoRenderView(getRendererViewStreamSize: getRendererViewStreamSize,
                                rendererView: self.rendererView,
                                scale: $scale)
            .gesture(TapGesture(count: 2).onEnded({
                if scale != 1.0 {
                    scale = 1.0
                } else {
                    scale = 2.0
                }
            }))
    }

}
