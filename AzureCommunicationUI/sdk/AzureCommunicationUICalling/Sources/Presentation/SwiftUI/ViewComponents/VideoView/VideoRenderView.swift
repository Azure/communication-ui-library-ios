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
        DefaultLogger.debugStatic("testpip: update")
        guard rendererView !== self.rendererView ||
              rendererView.superview !== self else {
            return
        }

        rendererView.backgroundColor = .red

        DefaultLogger.debugStatic("testpip: removeFromSuperview")
        rendererView.removeFromSuperview()
        for view in subviews {
            view.removeFromSuperview()
        }
        DefaultLogger.debugStatic("testpip: addSubview")

        rendererView.frame.size = self.frame.size
        addSubview(rendererView)

        DefaultLogger.debugStatic("testpip: superview != nil \(rendererView.superview != nil)")
        DefaultLogger.debugStatic("testpip: window != nil \(rendererView.window != nil)")

        DefaultLogger.debugStatic("testpip: rendererView size \(rendererView.frame.size)")
        DefaultLogger.debugStatic("testpip: self size \(self.frame.size)")

        self.rendererView = rendererView
    }
}
