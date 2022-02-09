//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import Combine
import AzureCommunicationCalling

struct ParticipantGridCellVideoView: View {

    private struct Constants {
        static let homebarHeight: CGFloat = 22
        static let borderColor = Color(StyleProvider.color.primaryColor)
    }

    let rendererView: UIView
    let getRemoteParticipantScreenShareVideoStreamRenderer: () -> VideoStreamRenderer?
    let zoomable: Bool
    @Binding var isSpeaking: Bool
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType
    @State private var scale: CGFloat = 1.0

    var body: some View {
        let lanscapeHasHomeBar = (screenSizeClass == .iphoneLandscapeScreenSize
                                  && UIDevice.current.hasHomeBar)
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 0) {
                GeometryReader { geometry in
                    if zoomable {
                        zoomableVideoRenderView
                            .frame(width: geometry.size.width - 0,
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
        VideoRendererView(rendererView: self.rendererView)
    }

    var zoomableVideoRenderView: some View {
        ZoomableVideoRenderView(getRemoteParticipantScreenShareVideoStreamRenderer:
                                    getRemoteParticipantScreenShareVideoStreamRenderer,
                                rendererView: self.rendererView,
                                scale: $scale).gesture(TapGesture(count: 2).onEnded({}))
    }
}
