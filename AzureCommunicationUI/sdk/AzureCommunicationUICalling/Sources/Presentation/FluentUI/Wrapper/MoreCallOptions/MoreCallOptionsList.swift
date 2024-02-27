//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct MoreCallOptionsList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var viewModel: MoreCallOptionsListViewModel
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<DrawerListItemViewModel> {
        let controller = MoreCallOptionsListViewController(sourceView: sourceView,
                                                           isRightToLeft: layoutDirection == .rightToLeft)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<DrawerListItemViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: viewModel.items)
    }

    static func dismantleUIViewController(_ controller: DrawerContainerViewController<DrawerListItemViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
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
