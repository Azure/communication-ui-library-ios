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

        // Setup scrollview and render view
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
                scrollView.setZoomScale(Constants.initialMinZoomScale,
                                        animated: true)
            }
        }

        func videoStreamRenderer(didRenderFirstFrameWithSize size: CGSize) {
            streamSize = size
        }
    }
}
