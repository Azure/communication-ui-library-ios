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
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        rendererView?.frame = bounds
    }

    func update(rendererView: UIView) {
        guard rendererView !== self.rendererView ||
              rendererView.superview !== self else {
            return
        }

        rendererView.removeFromSuperview()
        for view in subviews {
            view.removeFromSuperview()
        }
        addSubview(rendererView)
        self.rendererView = rendererView
    }
}
