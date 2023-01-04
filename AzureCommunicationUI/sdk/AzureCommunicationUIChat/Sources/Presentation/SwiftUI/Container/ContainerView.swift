//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContainerView: View {
    let viewFactory: CompositeViewFactoryProtocol
    let isRightToLeft: Bool

    var body: some View {
        viewFactory.makeChatView()
        .environment(\.layoutDirection, isRightToLeft ? .rightToLeft : .leftToRight)
    }
}
