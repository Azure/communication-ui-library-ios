//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CaptionsLanguageListView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    @ObservedObject var viewModel: CaptionsLanguageListViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> CaptionsLanguageListViewController {
        let controller = CaptionsLanguageListViewController(viewModel: viewModel)
        return controller
    }

    func updateUIViewController(_ uiViewController: CaptionsLanguageListViewController, context: Context) {
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<SelectableDrawerListItemViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: getCaptionsLanguageList())
    }

    static func dismantleUIViewController(_ controller:
                                          DrawerContainerViewController<SelectableDrawerListItemViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
    }

    private func getCaptionsLanguageList() -> [SelectableDrawerListItemViewModel] {
        return viewModel.supportedLanguages
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
