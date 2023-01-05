//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// The Chat Composite View is a view component for a single chat thread
public struct ChatCompositeView: View {
    let chatAdapter: ChatAdapter
    let viewFactory: CompositeViewFactoryProtocol

    /// Create an instance of ChatCompositeView with chatAdapter for a single chat thread
    /// - Parameters:
    ///    - chatAdapter: The required parameter to create a view component
    public init(with chatAdapter: ChatAdapter) {
        self.chatAdapter = chatAdapter
        self.viewFactory = self.chatAdapter.compositeViewFactory!
    }

    /// The view body would be used to render the ChatCompositeView
    public var body: some View {
        VStack {
            ContainerView(viewFactory: self.viewFactory)
        }
    }
}
