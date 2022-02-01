//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import AzureCommunicationCalling

struct ZoomableVideoRenderView: UIViewRepresentable {
    let getRemoteParticipantScreenShareVideoStreamRenderer: () -> VideoStreamRenderer?
    var rendererView: UIView!
    var scrollView = UIScrollView()
    var zoomToRect: CGRect = .zero
    @Binding var scale: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        getRemoteParticipantScreenShareVideoStreamRenderer()?.delegate = context.coordinator

        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 4
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = .fast
        scrollView.zoomScale = scale

        rendererView!.translatesAutoresizingMaskIntoConstraints = true
        rendererView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rendererView!.frame = scrollView.bounds
        scrollView.addSubview(rendererView!)
        scrollView.contentSize = rendererView.bounds.size

        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator,
                                                      action: #selector(Coordinator.doubleTapped))

        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delegate = context.coordinator
        scrollView.addGestureRecognizer(doubleTapGesture)
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, scale: $scale)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // trying to fix the zoom issue (screen blury upon orientation change)
        if uiView.zoomScale != scale {
            uiView.setZoomScale(1.0, animated: true)
        }
    }

    mutating func zoomScrollView(basedOn point: CGPoint, scale: CGFloat) {
        // Normalize current content size back to content scale of 1.0
        var contentSize = CGSize()
        contentSize.width = (self.scrollView.contentSize.width / self.scrollView.zoomScale)
        contentSize.height = (self.scrollView.contentSize.height / self.scrollView.zoomScale)

        // translate the zoom point to relative to the content rect
        var zoomPoint = CGPoint()
        zoomPoint.x = (point.x / self.scrollView.bounds.size.width) * contentSize.width
        zoomPoint.y = (point.y / self.scrollView.bounds.size.height) * contentSize.height

        // derive the size of the region to zoom to
        var zoomSize = CGSize()
        zoomSize.width = self.scrollView.bounds.size.width / scale // or 2.0
        zoomSize.height = self.scrollView.bounds.size.height / scale // or 2.0

        // offset the zoom rect so the actual zoom point is in the middle of the rectangle
        var zoomRect = CGRect()
        zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0
        zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0
        zoomRect.size.width = zoomSize.width
        zoomRect.size.height = zoomSize.height
        zoomToRect = zoomRect

        if scale == self.scrollView.maximumZoomScale {
            scrollView.zoom(to: zoomRect, animated: true) // turn off for testing
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate, RendererDelegate {

        @Binding private var newScale: CGFloat
        private var streamSize: CGSize = .zero
        private var rendererView: ZoomableVideoRenderView

        init(_ rendererView: ZoomableVideoRenderView,
             scale: Binding<CGFloat>) {
            self.rendererView = rendererView
            _newScale = scale
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            newScale = scale
        }

        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            // TBD
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let boundedZoomScale = min(scrollView.zoomScale, scrollView.maximumZoomScale)
            if boundedZoomScale > 1 {

                let aspectRatioVideoStream = self.streamSize != .zero ?
                    self.streamSize.width / self.streamSize.height : 1.6

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

            let currentScale = newScale
            let minScale = 1.0
            let maxScale = 4.0

            if minScale == maxScale && minScale > 1 {
                return
            }

            let toScale = maxScale
            let finalScale = (currentScale == minScale) ? toScale : minScale
            newScale = finalScale

            rendererView.zoomScrollView(basedOn: point, scale: finalScale) // was newScale
        }

        // MARK: RendererDelegate

        func videoStreamRenderer(didRenderFirstFrame renderer: VideoStreamRenderer) {
            streamSize = CGSize(width: Int(renderer.size.width), height: Int(renderer.size.height))
        }

        func videoStreamRenderer(didFailToStart renderer: VideoStreamRenderer) {
        }
    }
}
