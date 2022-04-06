//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CompositeLeaveCallConfirmationList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var viewModel: [LeaveCallConfirmationViewModel]
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<LeaveCallConfirmationViewModel> {
        let controller = LeaveCallConfirmationListViewController(items: getLeaveCallConfirmationList(),
                                                                 sourceView: sourceView,
                                                                 showHeader: true)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<LeaveCallConfirmationViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: getLeaveCallConfirmationList())
    }

    static func dismantleUIViewController(_ controller: DrawerContainerViewController<LeaveCallConfirmationViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
    }

    private func getLeaveCallConfirmationList() -> [LeaveCallConfirmationViewModel] {
        return viewModel
    }

    class Coordinator: NSObject, DrawerControllerDelegate {
        @Binding var isPresented: Bool

        init(isPresented: Binding<Bool>) {
            self._isPresented = isPresented
        }

        func drawerControllerDidDismiss(_ controller: DrawerController) {
            isPresented = false
        }
    }
}
