//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct ZoomableVideoRenderView: UIViewRepresentable {

    private struct Constants {
        static let smallScreenMaxScale: CGFloat = 2.0
        static let smallScreenMinScale: CGFloat = 0.5
        static let smallScreenMaxLength: CGFloat = 850

        static let maxScale: CGFloat = 4.0
        static let minScale: CGFloat = 1.0

        static let defaultAspectRatio: CGFloat = 1.6 // 16: 10 aspect ratio
        static let maxTapRequired: Int = 2

        static let isSmallScreen: Bool = UIScreen.isScreenSmall(Constants.smallScreenMaxLength)
        static let initialMinZoomScale: CGFloat = isSmallScreen ? Constants.smallScreenMinScale : Constants.minScale
        static let initialMaxZoomScale: CGFloat = isSmallScreen ? Constants.smallScreenMaxScale : Constants.maxScale
    }
    let videoRendererViewInfo: ParticipantRendererViewInfo!
    weak var rendererViewManager: RendererViewManager?
    private var rendererView: UIView!
    private var zoomToRect: CGRect = .zero

    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType
    @Environment(\.appPhase) var appPhase: AppStatus

    init(videoRendererViewInfo: ParticipantRendererViewInfo,
         rendererViewManager: RendererViewManager?) {
        self.videoRendererViewInfo = videoRendererViewInfo
        self.rendererView = videoRendererViewInfo.rendererView
        self.rendererViewManager = rendererViewManager
    }

    func makeUIView(context: Context) -> UIScrollView {
        // Creates a content view for scrollview, that holds on to the rendererView
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Setup scrollview and renderview
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = Constants.initialMaxZoomScale
        scrollView.minimumZoomScale = Constants.initialMinZoomScale
        scrollView.bouncesZoom = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast

        rendererView!.translatesAutoresizingMaskIntoConstraints = true
        rendererView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rendererView!.frame = scrollView.bounds

        contentView.addSubview(rendererView!)
        scrollView.addSubview(contentView)
        scrollView.contentSize = rendererView.bounds.size
        scrollView.zoomScale = Constants.initialMinZoomScale

        // Double tap action
        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                      action: #selector(Coordinator.doubleTapped))
        doubleTapGesture.numberOfTapsRequired = Constants.maxTapRequired
        doubleTapGesture.delegate = context.coordinator
        rendererViewManager?.didRenderFirstFrame = context.coordinator.videoStreamRenderer(didRenderFirstFrameWithSize:)

        scrollView.addGestureRecognizer(doubleTapGesture)
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        guard appPhase == .foreground else {
            return
        }
        // Set zoom scale per each orientation to fix the zoom issue (blury screen upon orientation change)
        let initialMinZoomScale = Constants.initialMinZoomScale
        let iPhoneOrientationChanged = scrollView.zoomScale != initialMinZoomScale
                                && (scrollView.contentSize == .zero)
        let isiPadLandscape = UIDevice.current.orientation.isLandscape && isiPadScreen()
        let isiPadPortrait = UIDevice.current.orientation.isPortrait && isiPadScreen()

        let iPadOrientationChanged = (isiPadLandscape && scrollView.contentSize.height > scrollView.contentSize.width)
                                  || (isiPadPortrait && scrollView.contentSize.height < scrollView.contentSize.width)

        if iPhoneOrientationChanged || iPadOrientationChanged {
            scrollView.setZoomScale(initialMinZoomScale, animated: true)
        } else if appPhase == .foreground {
            restoreRendererViewZoomStatus(scrollView)
        }
    }

    /// Zooms to a specific area in scroll view
    mutating func zoom(_ scrollView: UIScrollView, basedOn point: CGPoint, scale: CGFloat) {
        // Normalize current content size back to content scale of Constants.minScale
        var contentSize = CGSize()

        contentSize.width = (scrollView.frame.width / scrollView.zoomScale)
        contentSize.height = (scrollView.frame.height / scrollView.zoomScale)

        // translate the zoom point to relative to the content rect
        var zoomPoint = CGPoint()
        zoomPoint.x = (point.x / scrollView.bounds.size.width) * contentSize.width
        zoomPoint.y = (point.y / scrollView.bounds.size.height) * contentSize.height

        // derive the size of the region to zoom to
        var zoomSize = CGSize()
        zoomSize.width = scrollView.bounds.size.width / scale
        zoomSize.height = scrollView.bounds.size.height / scale

        // offset the zoom rect so the actual zoom point is in the middle of the rectangle
        var zoomRect = CGRect()
        zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0
        zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0
        zoomRect.size.width = zoomSize.width
        zoomRect.size.height = zoomSize.height
        zoomToRect = zoomRect

        if scale == scrollView.maximumZoomScale {
            scrollView.zoom(to: zoomRect, animated: true)
        } else {
            scrollView.setZoomScale(Constants.initialMinZoomScale,
                                    animated: true)
        }
    }

    func updateRendererViewSize(_ scrollView: UIScrollView) {
        guard scrollView.frame != .zero else {
            return
        }
        let scrollViewFrame = scrollView.frame
        let initialMinZoomScale = Constants.initialMinZoomScale
        let newFrame = CGRect(origin: scrollViewFrame.origin,
                              size: CGSize(width: scrollViewFrame.width * (1 / initialMinZoomScale),
                                           height: scrollViewFrame.height * (1 / initialMinZoomScale)))
        self.rendererView.frame = newFrame
        scrollView.setZoomScale(initialMinZoomScale, animated: false)
        scrollView.contentSize = CGSize(width: scrollViewFrame.width, height: scrollViewFrame.height)
    }

    func restoreRendererViewZoomStatus(_ scrollView: UIScrollView) {
        guard scrollView.frame != .zero else {
            return
        }
        let initialMinZoomScale = Constants.initialMinZoomScale
        let currentScale = scrollView.zoomScale
        guard initialMinZoomScale != currentScale, zoomToRect != .zero else {
            return
        }
        updateRendererViewSize(scrollView)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
            // For some reason the zooming does not work without this explict async call for scrollview.
            // Added it for now, and will continue to find improvement.
            scrollView.zoom(to: zoomToRect, animated: false)
        }
    }

    mutating func updateZoomRect(rect: CGRect) {
        self.zoomToRect = rect
    }

    private func isiPadScreen() -> Bool {
        return screenSizeClass == .ipadScreenSize
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {

        private var streamSize: CGSize = .zero
        private var zoomableRenderView: ZoomableVideoRenderView

        init(_ rendererView: ZoomableVideoRenderView) {
            self.zoomableRenderView = rendererView
            super.init()
            streamSize = rendererView.videoRendererViewInfo.streamSize
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            let visible = scrollView.convert(scrollView.bounds, to: scrollView.subviews.first)
            self.zoomableRenderView.updateZoomRect(rect: visible)
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let visible = scrollView.convert(scrollView.bounds, to: scrollView.subviews.first)
            self.zoomableRenderView.updateZoomRect(rect: visible)
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView) {
            let visible = scrollView.convert(scrollView.bounds, to: scrollView.subviews.first)
            self.zoomableRenderView.updateZoomRect(rect: visible)
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let initialMinZoomScale = Constants.initialMinZoomScale
            let boundedZoomScale = min(scrollView.zoomScale, scrollView.maximumZoomScale) * (1 / initialMinZoomScale)

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
            guard let scrollView = gesture.view as? UIScrollView else {
                return
            }
            let point = gesture.location(in: gesture.view)

            let currentScale = scrollView.zoomScale
            let minScale = Constants.initialMinZoomScale
            let maxScale = Constants.initialMaxZoomScale

            let finalScale = (currentScale == minScale) ? maxScale : minScale

            zoomableRenderView.zoom(scrollView, basedOn: point, scale: finalScale)
        }

        func videoStreamRenderer(didRenderFirstFrameWithSize size: CGSize) {
            streamSize = size
        }
    }
}
