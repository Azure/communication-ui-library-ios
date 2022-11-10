//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI
import UIKit

struct CompositeParticipantsList: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var isInfoHeaderDisplayed: Bool
    @Binding var isVoiceOverEnabled: Bool
    @ObservedObject var viewModel: ParticipantsListViewModel
    @ObservedObject var avatarViewManager: AvatarViewManager
    @Environment(\.layoutDirection) var layoutDirection: LayoutDirection
    let sourceView: UIView

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented,
                    isInfoHeaderDisplayed: $isInfoHeaderDisplayed,
                    isVoiceOverEnabled: $isVoiceOverEnabled)
    }

    func makeUIViewController(context: Context) -> DrawerContainerViewController<ParticipantsListCellViewModel> {
        let controller = ParticipantsListViewController(sourceView: sourceView,
                                                        avatarViewManager: avatarViewManager,
                                                        isRightToLeft: layoutDirection == .rightToLeft)
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
        @Binding var isInfoHeaderDisplayed: Bool
        @Binding var isVoiceOverEnabled: Bool

        init(isPresented: Binding<Bool>,
             isInfoHeaderDisplayed: Binding<Bool>,
             isVoiceOverEnabled: Binding<Bool>) {
            self._isPresented = isPresented
            self._isInfoHeaderDisplayed = isInfoHeaderDisplayed
            self._isVoiceOverEnabled = isVoiceOverEnabled
        }

        func drawerControllerDidDismiss(_ controller: DrawerController) {
            isPresented = false
            if !isVoiceOverEnabled {
                isInfoHeaderDisplayed = false
            }
        }
    }
}
