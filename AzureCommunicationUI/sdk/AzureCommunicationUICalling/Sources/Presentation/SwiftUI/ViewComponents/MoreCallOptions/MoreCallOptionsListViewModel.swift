//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine

class MoreCallOptionsListViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let dispatchAction: ActionDispatch
    private let showSharingViewAction: () -> Void
    private let showSupportFormAction: () -> Void
    private let showCaptionsViewAction: () -> Void
    private let showRttViewAction: () -> Void
    private let controlBarOptions: CallScreenControlBarOptions?
    private let isCaptionsAvailable: Bool
    private let isSupportFormAvailable: Bool
    private let isRttAvailable: Bool
    private var isRttEnabled: Bool
    @Published var items: [BaseDrawerItemViewModel]
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         buttonActions: ButtonActions,
         controlBarOptions: CallScreenControlBarOptions?,
         isCaptionsAvailable: Bool,
         isSupportFormAvailable: Bool,
         isRttAvailable: Bool,
         buttonViewDataState: ButtonViewDataState,
         dispatchAction: @escaping ActionDispatch
    ) {
        self.dispatchAction = dispatchAction
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = false
        self.isRttEnabled = false
        self.showSharingViewAction = buttonActions.showSharingViewAction
        self.showSupportFormAction = buttonActions.showSupportFormAction
        self.showCaptionsViewAction = buttonActions.showCaptionsViewAction
        self.showRttViewAction = buttonActions.showRttViewAction
        self.controlBarOptions = controlBarOptions
        self.isCaptionsAvailable = isCaptionsAvailable
        self.isSupportFormAvailable = isSupportFormAvailable
        self.isRttAvailable = isRttAvailable
        self.items = []

        self.generateItems(buttonViewDataState)
    }

    func update(navigationState: NavigationState,
                rttState: RttState,
                visibilityState: VisibilityState,
                buttonViewDataState: ButtonViewDataState) {
        isDisplayed = visibilityState.currentStatus == .visible && navigationState.moreOptionsVisible
        isRttEnabled = rttState.isRttOn

        self.generateItems(buttonViewDataState)
    }
    private func generateItems(_ buttonViewDataState: ButtonViewDataState) {
        var items: [BaseDrawerItemViewModel] = []

        if isCaptionsAvailable && buttonViewDataState.liveCaptionsButton?.visible ?? true {
            let captionsInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.captionsListTitile),
                accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                accessibilityTraits: [.isButton],
                action: showCaptionsViewAction,
                startCompositeIcon: .closeCaptions,
                endIcon: .rightChevron,
                isEnabled: buttonViewDataState.liveCaptionsButton?.enabled ?? true
            )
            items.append(captionsInfoModel)
        }
        if buttonViewDataState.shareDiagnosticsButton?.visible ?? true {
            let shareDebugInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
                accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
                accessibilityTraits: [.isButton],
                action: showSharingViewAction,
                startCompositeIcon: .share,
                isEnabled: buttonViewDataState.shareDiagnosticsButton?.enabled ?? true
            )

            items.append(shareDebugInfoModel)
        }

        if isSupportFormAvailable && buttonViewDataState.reportIssueButton?.visible ?? true {
            let reportErrorInfoModel = DrawerGenericItemViewModel(
                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
                accessibilityTraits: [.isButton],
                action: showSupportFormAction,
                startCompositeIcon: .personFeedback,
                isEnabled: buttonViewDataState.reportIssueButton?.enabled ?? true
            )

            items.append(reportErrorInfoModel)
        }

        if isRttAvailable && buttonViewDataState.rttButton?.visible ?? true {
            let rttInfoModel = IconTextActionListItemViewModel(
                title: localizationProvider.getLocalizedString(.rttTurnOn),
                isEnabled: !isRttEnabled,
                startCompositeIcon: CompositeIcon.rtt,
                accessibilityIdentifier: "",
                confirmTitle: localizationProvider.getLocalizedString(.rttAlertTitle),
                confirmMessage: localizationProvider.getLocalizedString(.rttAlertMessage),
                confirmAccept: localizationProvider.getLocalizedString(.rttAlertTurnOn),
                confirmDeny: localizationProvider.getLocalizedString(.rttAlertDismiss),
                accept: showRttViewAction,
                deny: { self.dispatchAction(.hideDrawer) }

            )
            items.append(rttInfoModel)
        }

        buttonViewDataState.callScreenCustomButtonsState.forEach({ customButton in
            if customButton.visible {
                let customButtonModel = DrawerGenericItemViewModel(
                    title: customButton.title,
                    accessibilityIdentifier: "",
                    accessibilityTraits: [.isButton],
                    action: {
                        guard let optionsButton = self.controlBarOptions?.customButtons.first(where: { optionsButton in
                            optionsButton.id == customButton.id
                        }) else {
                            return
                        }
                        optionsButton.onClick(optionsButton)
                        self.dispatchAction(.hideDrawer)
                    },
                    startIcon: customButton.image,
                    isEnabled: customButton.enabled
                )
                items.append(customButtonModel)
            }
        })
        self.items = items
    }
}
