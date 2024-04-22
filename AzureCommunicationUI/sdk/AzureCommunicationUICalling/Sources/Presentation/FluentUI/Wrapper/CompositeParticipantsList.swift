//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeParticipantsList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: ParticipantsListViewModel
    @ObservedObject var avatarViewManager: AvatarViewManager
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<ParticipantsListCellViewModel> {
        let controller = ParticipantsListViewController(sourceView: sourceView,
                                                        avatarViewManager: avatarViewManager,
                                                        isRightToLeft: layoutDirection == .rightToLeft,
                                                        admintAll: viewModel.admitAll,
                                                        declineAll: viewModel.declineAll,
                                                        admitParticipant: viewModel.admitParticipant,
                                                        declineParticipant: viewModel.declineParticipant,
                                                        waitingInLobby: viewModel.getWaitingInLobby(),
                                                        inTheCall: viewModel.getInTheCall(),
                                                        admitAllButtonText: viewModel.getAdmitAllButtonText(),
                                                        confirmTitleAdmitParticipant:
                                                            viewModel.getConfirmTitleAdmitParticipant(),
                                                        confirmTitleAdmitAll: viewModel.getConfirmTitleAdmitAll(),
                                                        confirmAdmit: viewModel.getConfirmAdmit(),
                                                        confirmDecline: viewModel.getConfirmDecline()
        )
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: DrawerContainerViewController<ParticipantsListCellViewModel>,
                                context: Context) {
        uiViewController.updateDrawerList(items: getParticipantsList())
    }

    static func dismantleUIViewController(_ controller: DrawerContainerViewController<ParticipantsListCellViewModel>,
                                          coordinator: Coordinator) {
        controller.dismissDrawer()
    }

    private func getParticipantsList() -> [ParticipantsListCellViewModel] {
        return viewModel.sortedParticipants(with: avatarViewManager)
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
