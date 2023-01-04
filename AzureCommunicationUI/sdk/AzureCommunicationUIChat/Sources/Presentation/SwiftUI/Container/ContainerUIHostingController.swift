//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class ContainerUIHostingController: UIHostingController<ContainerUIHostingController.Root> {
    private let cancelBag = CancelBag()

    init(rootView: ContainerView,
         isRightToLeft: Bool) {
        super.init(rootView: Root(containerView: rootView))
        UIView.appearance().semanticContentAttribute = isRightToLeft ?
            .forceRightToLeft : .forceLeftToRight
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    struct Root: View {
        let containerView: ContainerView

        var body: some View {
            containerView
        }
    }

    // MARK: Prefers Home Indicator Auto Hidden
}

 extension ContainerUIHostingController: UIViewControllerTransitioningDelegate {}
