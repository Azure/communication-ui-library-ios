//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct Icon: View {
    var name: CompositeIcon?
    var uiImage: UIImage?
    var size: CGFloat

    var body: some View {
        if let uiImage = uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: size, height: size, alignment: .center)
        }
        if let name = name {
            StyleProvider.icon.getImage(for: name)
                .resizable()
                .frame(width: size, height: size, alignment: .center)
        }
    }
}
