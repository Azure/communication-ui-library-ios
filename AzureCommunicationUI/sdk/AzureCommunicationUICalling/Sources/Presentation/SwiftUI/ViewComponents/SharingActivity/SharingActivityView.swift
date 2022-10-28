//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SharingActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    let sourceView: UIView
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> SharingActivityContainerController {
        return SharingActivityContainerController(activityItems: activityItems,
                                           applicationActivities: applicationActivities,
                                           sourceView: sourceView) {
            self.isPresented = false
        }
    }

    func updateUIViewController(_ uiViewController: SharingActivityContainerController, context: Context) {}

    static func dismantleUIViewController(_ controller: SharingActivityContainerController,
                                          coordinator: Coordinator) {
        controller.dismissPresentedController()
    }
}
