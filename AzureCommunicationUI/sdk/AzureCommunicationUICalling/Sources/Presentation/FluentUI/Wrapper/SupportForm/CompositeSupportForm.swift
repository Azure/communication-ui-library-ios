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

    func makeUIViewController(context: Context) -> SingleViewDrawerContainerViewController {
        let controller = SingleViewDrawerContainerViewController(sourceView: sourceView)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: SingleViewDrawerContainerViewController,
                                context: Context) {
    }

    static func dismantleUIViewController(
        _
        controller: SingleViewDrawerContainerViewController,
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
