//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine

struct ParticipantGridCellVideoView: View {

    private struct Constants {
        static let homebarHeight: CGFloat = 22
        static let borderColor = Color(StyleProvider.color.primaryColor)
    }

    var videoRendererViewInfo: ParticipantRendererViewInfo!
    let zoomable: Bool
    @Binding var isSpeaking: Bool
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    var body: some View {
        let lanscapeHasHomeBar = (screenSizeClass == .iphoneLandscapeScreenSize
                                  && UIDevice.current.hasHomeBar)
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 0) {
                GeometryReader { geometry in
                    if zoomable {
                        // reduce height as work-around to resolve the double tap issue, when lanscapeHasHomeBar is true
                        // To be improved in the next PR
                        zoomableVideoRenderView
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height - (lanscapeHasHomeBar ? Constants.homebarHeight : 0),
                                   alignment: .center)
                    } else {
                        videoRenderView
                    }
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
            isSpeaking && !isMuted ? RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Constants.borderColor, lineWidth: 4) : nil
        ).animation(.default)
    }

    var videoRenderView: some View {
        VideoRendererView(rendererView: videoRendererViewInfo.rendererView)
    }

    var zoomableVideoRenderView: some View {
        ZoomableVideoRenderView(videoRendererViewInfo: videoRendererViewInfo)
                                .gesture(TapGesture(count: 2).onEnded({}))
        // The double tap action does nothing. This is a work around to resolve the double tap
        // interference issue with single tap action from Calling view.
        // To be improved in the next PR.
    }
}
