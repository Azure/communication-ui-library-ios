//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeLeaveCallConfirmationList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    var viewModel: LeaveCallConfirmationListViewModel
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<DrawerListItemViewModel> {
        let controller = LeaveCallConfirmationListViewController(sourceView: sourceView,
                                                                 headerName: viewModel.headerName,
                                                                 isRightToLeft: layoutDirection == .rightToLeft)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<DrawerListItemViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: getLeaveCallConfirmationList())
    }

    static func dismantleUIViewController(_ controller: DrawerContainerViewController<DrawerListItemViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
    }

    private func getLeaveCallConfirmationList() -> [DrawerListItemViewModel] {
        return viewModel.listItemViewModel
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
