//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct ZoomableVideoRenderView: UIViewRepresentable {
    var rendererView: UIView!
    @Binding var scale: CGFloat

    func makeUIView(context: Context) -> UIScrollView {
        // set up the UIScrollView
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator  // for viewForZooming(in:)
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
        Coordinator(self, scale: $scale)
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        uiView.setZoomScale(scale, animated: true)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, UIScrollViewDelegate {
        @Binding private var newScale: CGFloat
        private var scrollView: ZoomableVideoRenderView
        init(_ scrollView: ZoomableVideoRenderView, scale: Binding<CGFloat>) {
            self.scrollView = scrollView
            _newScale = scale
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first // hostingController.view
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            newScale = scale
        }
    }
}
