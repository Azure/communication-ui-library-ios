//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import FluentUI
import SwiftUI

struct ParticipantGridCellVideoView: View {
    var videoRendererViewInfo: ParticipantRendererViewInfo!
    let rendererViewManager: RendererViewManager?
    let zoomable: Bool
    @Binding var isSpeaking: Bool
    @Binding var displayName: String?
    @Binding var isMuted: Bool
    @Binding var rawVideoBuffer: CVPixelBuffer?
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            VStack(alignment: .center, spacing: 0) {
                if zoomable {
                    zoomableVideoRenderView
                        .prefersHomeIndicatorAutoHidden(UIDevice.current.hasHomeBar)
                } else {
                    GeometryReader { geometry in
                        RawVideoView(cvPixelBuffer: $rawVideoBuffer)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }

            ParticipantTitleView(displayName: $displayName,
                                 isMuted: $isMuted,
                                 isHold: .constant(false),
                                 titleFont: Fonts.caption1.font,
                                 mutedIconSize: 14)
                .padding(.vertical, 2)
                .background(Color(StyleProvider.color.overlay))
                .clipShape(RoundedRectangle(cornerRadius: 3))
                .padding(.leading, 4)
                .padding(.bottom, screenSizeClass == .iphoneLandscapeScreenSize
                    && UIDevice.current.hasHomeBar ? 16 : 4)

        }.overlay(
            isSpeaking && !isMuted ? RoundedRectangle(cornerRadius: 4)
                .strokeBorder(Color(StyleProvider.color.primaryColor), lineWidth: 4) : nil
        ).animation(.default)
    }

    var videoRenderView: some View {
        VideoRendererView(rendererView: videoRendererViewInfo.rendererView)
    }

    var zoomableVideoRenderView: some View {
        ZoomableVideoRenderView(videoRendererViewInfo: videoRendererViewInfo,
                                rendererViewManager: rendererViewManager)
                                .gesture(TapGesture(count: 2).onEnded({}))
        // The double tap action does nothing. This is a work around to
        // prevent the single-tap gesture (in CallingView) from being recognized
        // until after the double-tap gesture  recognizer (in ZoomableVideoRenderView) explicitly
        // reaches the failed state, which happens when the touch sequence contains only one tap.
    }
}

struct RawVideoView: UIViewRepresentable {
    @Binding var cvPixelBuffer: CVPixelBuffer?

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Get the pixel buffer from your video stream
        guard let pixelBuffer = cvPixelBuffer else {
            return
        }

        // Create a CIImage from the pixel buffer
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)

        // Create a UIImage from the CIImage
        let uiImage = UIImage(ciImage: ciImage)

        // Update the UIImageView with the new UIImage
        uiView.image = uiImage
        uiView.contentMode = .scaleAspectFill
        uiView.animationDuration = TimeInterval()
    }
}
