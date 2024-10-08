//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct Icon: View {
    var name: CompositeIcon
    var size: CGFloat

    var body: some View {
        StyleProvider.icon.getImage(for: name)
            .resizable()
            .frame(width: size, height: size, alignment: .center)
    }
}

struct UIImageIcon: UIViewRepresentable {
    var icon: UIImage
    var size: CGFloat

    func makeUIView(context: Context) -> UIView {
        var imageView = UIImageView(image: icon)
        return imageView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

}
