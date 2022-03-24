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
        guard self.rendererView != rendererView
        else { return }

        rendererView.removeFromSuperview()
        for view in subviews {
            view.removeFromSuperview()
        }
        addSubview(rendererView)
        rendererView.translatesAutoresizingMaskIntoConstraints = false
        rendererView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rendererView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        rendererView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        rendererView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.rendererView = rendererView
    }
}
