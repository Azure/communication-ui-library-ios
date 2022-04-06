//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import Combine

struct VideoRendererView: UIViewRepresentable {
    let rendererView: UIView

    func makeUIView(context: Context) -> UIView {
        return rendererView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
