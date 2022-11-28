//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeAudioDevicesList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    @ObservedObject var viewModel: AudioDevicesListViewModel
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<SelectableDrawerListItemViewModel> {
        let controller = AudioDevicesListViewController(sourceView: sourceView,
                                                        isRightToLeft: layoutDirection == .rightToLeft)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<SelectableDrawerListItemViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: getAudioDevicesList())
    }

    static func dismantleUIViewController(_
                                          controller: DrawerContainerViewController<SelectableDrawerListItemViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
    }

    private func getAudioDevicesList() -> [SelectableDrawerListItemViewModel] {
        return viewModel.audioDevicesList
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
