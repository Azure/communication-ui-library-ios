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
        print("!!!\(Date())! makeUIView")
        rendererView.backgroundColor = .blue
        return VideoRendererUIView(rendererView: rendererView)
    }

    func updateUIView(_ uiView: VideoRendererUIView, context: Context) {
        rendererView.backgroundColor = .blue
        print("!!!\(Date())! updateUIView")
//        print("!!!\(Date())!uiview \(uiView)")
//        print("!!!\(Date())!uiview.subviews \(uiView.subviews)")
//        print("!!!\(Date())! renderview \(rendererView)")
//        print("!!!\(Date())! renderview.subviews \(rendererView.subviews)")
//        print("!!!\(Date())! uiView.superview?.subviews.count \(uiView.superview?.subviews.count ?? 0)")
        uiView.update(rendererView: rendererView)
//        print("!!!\(Date())! updateUIView end")
    }
}

class VideoRendererUIView: UIView {
    private var rendererView: UIView?

    init(rendererView: UIView) {
        super.init(frame: .zero)
        update(rendererView: rendererView)
        self.backgroundColor = .yellow
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(rendererView: UIView) {
        guard rendererView !== self.rendererView ||
              rendererView.superview !== self
        else {
//            print("!!!\(Date())!here")
//            print("!!!\(Date())!here 2 \(bounds)")
//            print("!!!\(Date())!here 2 rendererView.layer.zPosition \(rendererView.layer.zPosition)")
//            print("!!!\(Date())!here 2 self.layer.zPosition \(self.layer.zPosition)")
//            print("!!!\(Date())!here 2 self.subviews \(self.subviews)")
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
//        print("!!!\(Date())! update(rrendererView end")
//        print("!!!\(Date())! update(rrendererView self.subviews \(subviews)")
    }
}
