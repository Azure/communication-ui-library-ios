//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct ZoomableVideoRenderView: UIViewRepresentable {
    let getRendererViewStreamSize: () -> CGSize?
    var rendererView: UIView!
    @Binding var scale: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
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
        return scrollView
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, scale: $scale, getRendererViewStreamSize: getRendererViewStreamSize)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.setZoomScale(scale, animated: true)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding private var newScale: CGFloat
        private var streamSize: CGSize = .zero
        private var scrollView: ZoomableVideoRenderView
        private let getRendererViewStreamSize: () -> CGSize?

        init(_ scrollView: ZoomableVideoRenderView,
             scale: Binding<CGFloat>,
             getRendererViewStreamSize: @escaping () -> CGSize?) {

            self.scrollView = scrollView
            _newScale = scale
            self.getRendererViewStreamSize = getRendererViewStreamSize
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            newScale = scale
        }

        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            let size = getRendererViewStreamSize()
            streamSize = size ?? .zero
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
    }
}
