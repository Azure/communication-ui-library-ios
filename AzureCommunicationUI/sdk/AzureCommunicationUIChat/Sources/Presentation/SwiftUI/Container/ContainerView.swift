//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ContainerView: View {
    let viewFactory: CompositeViewFactoryProtocol

    var body: some View {
        viewFactory.makeChatView()
    }
}
