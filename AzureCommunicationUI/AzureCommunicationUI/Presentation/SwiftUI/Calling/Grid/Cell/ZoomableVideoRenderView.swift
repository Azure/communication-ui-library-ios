//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct ZoomableVideoRenderView: UIViewRepresentable {

    private struct Constants {
        static let maxScaleiPhone: CGFloat = 2.0
        static let minScaleiPhone: CGFloat = 0.5
        static let maxScaleiPad: CGFloat = 4.0
        static let minScaleiPad: CGFloat = 1.0
        static let defaultAspectRatio: CGFloat = 1.6 // 16: 10 aspect ratio
        static let maxTapRequired: Int = 2
    }
    var videoRendererViewInfo: VideoRendererViewInfo!
    private var rendererView: UIView!
    private var scrollView = UIScrollView()
    private var zoomToRect: CGRect = .zero
    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    init(videoRendererViewInfo: VideoRendererViewInfo) {
        self.videoRendererViewInfo = videoRendererViewInfo
        self.rendererView = videoRendererViewInfo.rendererView
    }

    func makeUIView(context: Context) -> UIScrollView {

        // Setup scrollview and renderview
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = isiPadScreen() ? Constants.maxScaleiPad : Constants.maxScaleiPhone
        scrollView.minimumZoomScale = isiPadScreen() ? Constants.minScaleiPad : Constants.minScaleiPhone
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.zoomScale = isiPadScreen() ? Constants.minScaleiPad : Constants.minScaleiPhone
        rendererView!.translatesAutoresizingMaskIntoConstraints = true
        rendererView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rendererView!.frame = scrollView.bounds
        scrollView.addSubview(rendererView!)
        scrollView.contentSize = rendererView.bounds.size

        // Double tap action
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                      action: #selector(Coordinator.doubleTapped))
        doubleTapGesture.numberOfTapsRequired = Constants.maxTapRequired
        doubleTapGesture.delegate = context.coordinator
        videoRendererViewInfo.delegate = context.coordinator
        scrollView.addGestureRecognizer(doubleTapGesture)
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, shouldShowScaleForiPad: isiPadScreen())
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Set zoom scale per each orientation to fix the zoom issue (blury screen upon orientation change)
        let orientationChangeZoomScale = isiPadScreen() ? Constants.minScaleiPad : Constants.minScaleiPhone
        let iPhoneOrientationChanged = uiView.zoomScale != orientationChangeZoomScale
                                && (uiView.contentSize == .zero)
        let isiPadLandscape = UIDevice.current.orientation.isLandscape && isiPadScreen()
        let isiPadPortrait = UIDevice.current.orientation.isPortrait && isiPadScreen()

        let iPadOrientationChanged = (isiPadLandscape && uiView.contentSize.height > uiView.contentSize.width)
                                  || (isiPadPortrait && uiView.contentSize.height < uiView.contentSize.width)

        if iPhoneOrientationChanged || iPadOrientationChanged {
            uiView.setZoomScale(orientationChangeZoomScale, animated: true)
        }
    }

    /// Zooms to a specific area in scroll view
    mutating func zoomScrollView(basedOn point: CGPoint, scale: CGFloat) {
        // Normalize current content size back to content scale of Constants.minScale
        var contentSize = CGSize()

        contentSize.width = (self.scrollView.frame.width / self.scrollView.zoomScale)
        contentSize.height = (self.scrollView.frame.height / self.scrollView.zoomScale)

        // translate the zoom point to relative to the content rect
        var zoomPoint = CGPoint()
        zoomPoint.x = (point.x / self.scrollView.bounds.size.width) * contentSize.width
        zoomPoint.y = (point.y / self.scrollView.bounds.size.height) * contentSize.height

        // derive the size of the region to zoom to
        var zoomSize = CGSize()
        zoomSize.width = self.scrollView.bounds.size.width / scale
        zoomSize.height = self.scrollView.bounds.size.height / scale

        // offset the zoom rect so the actual zoom point is in the middle of the rectangle
        var zoomRect = CGRect()
        zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0
        zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0
        zoomRect.size.width = zoomSize.width
        zoomRect.size.height = zoomSize.height
        zoomToRect = zoomRect

        if scale == self.scrollView.maximumZoomScale {
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            scrollView.setZoomScale(isiPadScreen() ? Constants.minScaleiPad : Constants.minScaleiPhone,
                                    animated: true)
        }
    }

    func updateRendererViewSize() {
        guard scrollView.frame != .zero else {
            return
        }
        let scrollViewFrame = scrollView.frame
        let adjustedScale = isiPadScreen() ? Constants.minScaleiPad : Constants.minScaleiPhone
        let newFrame = CGRect(origin: scrollViewFrame.origin,
                              size: CGSize(width: scrollViewFrame.width * (1 / adjustedScale),
                                           height: scrollViewFrame.height * (1 / adjustedScale)))
        self.rendererView.frame = newFrame
        self.scrollView.setZoomScale(adjustedScale, animated: false)
        self.scrollView.contentSize = CGSize(width: scrollViewFrame.width, height: scrollViewFrame.height)
    }

    func resetRendererView() {
        rendererView.frame = .zero
        scrollView.contentSize = .zero
    }

    func currentScrollViewZoomScale() -> CGFloat {
        return scrollView.zoomScale
    }

    private func isiPhonePortraitScreen() -> Bool {
        return screenSizeClass == .iphonePortraitScreenSize
    }

    private func isiPadScreen() -> Bool {
        return screenSizeClass == .ipadScreenSize
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate,
                        VideoScreenShareDelegate {

        private var streamSize: CGSize = .zero
        private var rendererView: ZoomableVideoRenderView
        private var shouldShowScaleForiPad: Bool

        init(_ rendererView: ZoomableVideoRenderView, shouldShowScaleForiPad: Bool) {
            self.rendererView = rendererView
            self.shouldShowScaleForiPad = shouldShowScaleForiPad
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let adjustedScale = shouldShowScaleForiPad ? Constants.minScaleiPad : Constants.minScaleiPhone
            let boundedZoomScale = min(scrollView.zoomScale, scrollView.maximumZoomScale) * (1 / adjustedScale)

            if boundedZoomScale > 1 {
                let aspectRatioVideoStream = self.streamSize != .zero ?
                self.streamSize.width / self.streamSize.height : Constants.defaultAspectRatio

                let spectRatioScrollView = scrollView.bounds.width / scrollView.bounds.height
                let scrollViewHasNarrowAspectRatio = spectRatioScrollView < aspectRatioVideoStream

                var videoContentWidth = scrollView.bounds.width
                var videoContentHeight = videoContentWidth / aspectRatioVideoStream

                if !scrollViewHasNarrowAspectRatio {
                    videoContentHeight = scrollView.bounds.height
                    videoContentWidth = videoContentHeight * aspectRatioVideoStream
                }

                let ratioW = scrollView.frame.width / videoContentWidth
                let ratioH = scrollView.frame.height / videoContentHeight

                let ratio = ratioW < ratioH ? ratioW:ratioH

                let newWidth = videoContentWidth * ratio
                let newHeight = videoContentHeight * ratio

                let left = 0.5 * (newWidth * boundedZoomScale > scrollView.frame.width ?
                                  (newWidth - scrollView.frame.width)
                                  : (scrollView.frame.width - scrollView.contentSize.width))
                let top = 0.5 * (newHeight * boundedZoomScale > scrollView.frame.height ?
                                 (!scrollViewHasNarrowAspectRatio ?
                                  (newHeight - scrollView.frame.height) :
                                    (scrollView.frame.height - scrollView.contentSize.height
                                     + (newHeight * boundedZoomScale - scrollView.frame.height)))
                                 : (scrollView.frame.height - scrollView.contentSize.height))

                scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
            } else {
                scrollView.contentInset = .zero
            }
        }

        @objc func doubleTapped(gesture: UITapGestureRecognizer) {
            let point = gesture.location(in: gesture.view)

            let currentScale = rendererView.currentScrollViewZoomScale()
            let minScale = shouldShowScaleForiPad ? Constants.minScaleiPad : Constants.minScaleiPhone
            let maxScale = shouldShowScaleForiPad ? Constants.maxScaleiPad: Constants.maxScaleiPhone

            let toScale = maxScale
            let finalScale = (currentScale == minScale) ? toScale : minScale

            rendererView.zoomScrollView(basedOn: point, scale: finalScale)
        }

        // MARK: VideoScreenShareDelegate

        func videoStreamRenderer(didRenderFirstFrameWithSize size: CGSize) {
            streamSize = size
            rendererView.updateRendererViewSize()
        }

        func videoStreamRendererDidFailToStart() {
            rendererView.resetRendererView()
        }
    }
}
