//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

struct CompositeParticipantMenu: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var viewModel: ParticipantMenuViewModel
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<DrawerListItemViewModel> {
        let controller = ParticipantMenuViewController(sourceView: sourceView,
                                                       isRightToLeft: layoutDirection == .rightToLeft,
                                                       participantName: viewModel.getParticipantName()
                                                       )
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
