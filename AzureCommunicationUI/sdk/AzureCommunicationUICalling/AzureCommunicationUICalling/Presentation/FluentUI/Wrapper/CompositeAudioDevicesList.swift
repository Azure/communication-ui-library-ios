//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

struct CompositeAudioDevicesList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: AudioDevicesListViewModel
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<AudioDevicesListCellViewModel> {
        let controller = AudioDevicesListViewController(items: getAudioDevicesList(),
                                                        sourceView: sourceView)
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<AudioDevicesListCellViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: getAudioDevicesList())
    }

    static func dismantleUIViewController(_ controller: DrawerContainerViewController<AudioDevicesListCellViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
    }

    private func getAudioDevicesList() -> [AudioDevicesListCellViewModel] {
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
