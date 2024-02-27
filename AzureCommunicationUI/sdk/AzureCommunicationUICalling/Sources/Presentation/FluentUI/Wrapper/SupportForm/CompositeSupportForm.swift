//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeSupportForm: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    @ObservedObject var viewModel: SupportFormViewModel
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<SupportFormViewModel> {
        let controller = CompositeSupportFormViewController(sourceView: sourceView)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<SupportFormViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: [viewModel])
    }

    static func dismantleUIViewController(_
                                          controller: DrawerContainerViewController<SelectableDrawerListItemViewModel>,
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
