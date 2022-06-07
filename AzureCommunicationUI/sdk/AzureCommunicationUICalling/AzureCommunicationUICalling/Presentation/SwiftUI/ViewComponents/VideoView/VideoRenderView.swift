//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import Combine

struct VideoRendererView: UIViewRepresentable {
    let rendererView: UIView

    func makeUIView(context: Context) -> VideoRendererUIView {
        return VideoRendererUIView(rendererView: rendererView)
    }

    func updateUIView(_ uiView: VideoRendererUIView, context: Context) {
        uiView.update(rendererView: rendererView)
    }
}

class VideoRendererUIView: UIView {
    private var rendererView: UIView?

    init(rendererView: UIView) {
        super.init(frame: .zero)
        update(rendererView: rendererView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(rendererView: UIView) {
        guard rendererView !== self.rendererView ||
              rendererView.superview !== self
        else {
            if self.rendererView?.frame != bounds {
                self.rendererView?.frame = bounds
            }

            return
        }

        rendererView.removeFromSuperview()
        for view in subviews {
            view.removeFromSuperview()
        }
        // the frame should be updated manually
        // as setting constrains may cause updateUIView(_ uiView: VideoRendererUIView, context: Context) call
        rendererView.translatesAutoresizingMaskIntoConstraints = true
        rendererView.frame = bounds
        rendererView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(rendererView)
        self.rendererView = rendererView
    }
}
