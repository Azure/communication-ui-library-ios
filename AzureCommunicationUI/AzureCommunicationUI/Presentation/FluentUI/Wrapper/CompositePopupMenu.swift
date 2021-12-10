//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CompositePopupMenu: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: AudioDeviceListViewModel
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<PopupMenuViewModel> {
        let controller = PopupMenuViewController(items: viewModel.audioDeviceList,
                                                 sourceView: sourceView)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<PopupMenuViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: viewModel.audioDeviceList)
    }

    static func dismantleUIViewController(_ uiViewController: DrawerContainerViewController<PopupMenuViewModel>,
                                          coordinator: Coordinator) {
        uiViewController.dismissDrawer()
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
