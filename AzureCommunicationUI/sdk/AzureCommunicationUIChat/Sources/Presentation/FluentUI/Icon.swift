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
