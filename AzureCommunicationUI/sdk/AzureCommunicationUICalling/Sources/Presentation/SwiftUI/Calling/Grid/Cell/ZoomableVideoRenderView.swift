//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct ZoomableVideoRenderView: UIViewRepresentable {

    private enum SmallScreenConstants {
        static let maxScale: CGFloat = 2.0
        static let minScale: CGFloat = 0.5
        static let maxLength: CGFloat = 850
    }

    private enum GeneralScreenConstants {
        static let maxScale: CGFloat = 4.0
        static let minScale: CGFloat = 1.0

        static let defaultAspectRatio: CGFloat = 1.6 // 16: 10 aspect ratio
        static let tapCount: Int = 2
    }

    private enum InitialZoomScaleConstants {
        static let isSmallScreen: Bool = UIScreen.isScreenSmall(SmallScreenConstants.maxLength)
        static let minScale: CGFloat = isSmallScreen ? SmallScreenConstants.minScale : GeneralScreenConstants.minScale
        static let maxScale: CGFloat = isSmallScreen ? SmallScreenConstants.maxScale : GeneralScreenConstants.maxScale
    }

    let videoRendererViewInfo: ParticipantRendererViewInfo!
    weak var rendererViewManager: RendererViewManager?

    init(videoRendererViewInfo: ParticipantRendererViewInfo,
         rendererViewManager: RendererViewManager?) {
        self.videoRendererViewInfo = videoRendererViewInfo
        self.rendererViewManager = rendererViewManager
    }

    func makeUIView(context: Context) -> UIScrollView {
        // Setup scrollview and render view
        let scrollView = UIScrollView()

        // Setup scrollview and render view
        setupScrollView(scrollView, context: context)

        // Add double tap action
        addDoubleTapGestureRecognizer(for: scrollView, coordinator: context.coordinator)
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        // check when updateUIView is called after makeUIView
        if let currentContentView = scrollView.subviews.first,
           currentContentView.subviews.first === videoRendererViewInfo.rendererView {
            return
        }
        // Remove rendererView from superview
        videoRendererViewInfo.rendererView.removeFromSuperview()
        // Remove subviews from the scroll view
        for view in scrollView.subviews {
            view.removeFromSuperview()
            for innerView in view.subviews {
                innerView.removeFromSuperview()
            }
        }

        // Setup scrollview and render view
        setupScrollView(scrollView, context: context)

        // Remove double tap action is already added
        if let gestures = scrollView.gestureRecognizers,
           let tapGestureRecognizer = gestures.first(where: { $0.numberOfTouches == GeneralScreenConstants.tapCount }) {
            scrollView.removeGestureRecognizer(tapGestureRecognizer)
        }

        // Add double tap action
        addDoubleTapGestureRecognizer(for: scrollView, coordinator: context.coordinator)
    }

    static func dismantleUIView(_ uiView: UIScrollView, coordinator: Coordinator) {
        uiView.delegate = nil
        for view in uiView.subviews {
            view.removeFromSuperview()
        }
    }

    private func addDoubleTapGestureRecognizer(for scrollView: UIScrollView,
                                               coordinator: Coordinator) {
        let doubleTapGesture = UITapGestureRecognizer(target: coordinator,
                                                      action: #selector(Coordinator.doubleTapped))
        doubleTapGesture.numberOfTapsRequired = GeneralScreenConstants.tapCount
        doubleTapGesture.delegate = coordinator
        rendererViewManager?.didRenderFirstFrame = coordinator.videoStreamRenderer(didRenderFirstFrameWithSize:)

        scrollView.addGestureRecognizer(doubleTapGesture)
    }

    private func setupScrollView(_ scrollView: UIScrollView,
                                 context: Context) {
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = InitialZoomScaleConstants.maxScale
        scrollView.minimumZoomScale = InitialZoomScaleConstants.minScale
        scrollView.bouncesZoom = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast

        // Creates a content view for scrollview, that contains the rendererView
        let contentView = UIView()
        scrollView.addSubview(contentView)
        scrollView.contentSize = scrollView.bounds.size

        // ZoomScale should be set before contentView.frame in order to resize contentView correctly
        scrollView.zoomScale = InitialZoomScaleConstants.minScale
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.frame = scrollView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        videoRendererViewInfo.rendererView.translatesAutoresizingMaskIntoConstraints = true
        videoRendererViewInfo.rendererView.frame = scrollView.bounds
        videoRendererViewInfo.rendererView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(videoRendererViewInfo.rendererView)
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

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let initialMinZoomScale = InitialZoomScaleConstants.minScale
            let boundedZoomScale = min(scrollView.zoomScale, scrollView.maximumZoomScale) * (1 / initialMinZoomScale)

            if boundedZoomScale > 1 {
                let aspectRatioVideoStream = self.streamSize != .zero ?
                self.streamSize.width / self.streamSize.height : GeneralScreenConstants.defaultAspectRatio

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
            let minScale = InitialZoomScaleConstants.minScale
            let maxScale = InitialZoomScaleConstants.maxScale

            let finalScale = (currentScale == minScale) ? maxScale : minScale

            zoom(scrollView, basedOn: point, scale: finalScale)
        }

        private func zoom(_ scrollView: UIScrollView, basedOn point: CGPoint, scale: CGFloat) {
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

            if scale == scrollView.maximumZoomScale {
                scrollView.zoom(to: zoomRect, animated: true)
            } else {
                scrollView.setZoomScale(InitialZoomScaleConstants.minScale,
                                        animated: true)
            }
        }

        func videoStreamRenderer(didRenderFirstFrameWithSize size: CGSize) {
            streamSize = size
        }
    }
}
