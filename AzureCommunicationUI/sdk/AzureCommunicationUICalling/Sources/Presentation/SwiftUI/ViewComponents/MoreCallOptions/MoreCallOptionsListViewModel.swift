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
    private let controlBarOptions: CallScreenControlBarOptions?
    private let isCaptionsAvailable: Bool
    private let isSupportFormAvailable: Bool
    @Published var items: [BaseDrawerItemViewModel]
    var isDisplayed: Bool

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         buttonActions: ButtonActions,
         controlBarOptions: CallScreenControlBarOptions?,
         isCaptionsAvailable: Bool,
         isSupportFormAvailable: Bool,
         buttonViewDataState: ButtonViewDataState,
         dispatchAction: @escaping ActionDispatch
    ) {
        self.dispatchAction = dispatchAction
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.isDisplayed = false
        self.showSharingViewAction = buttonActions.showSharingViewAction
        self.showSupportFormAction = buttonActions.showSupportFormAction
        self.showCaptionsViewAction = buttonActions.showCaptionsViewAction
        self.controlBarOptions = controlBarOptions
        self.isCaptionsAvailable = isCaptionsAvailable
        self.isSupportFormAvailable = isSupportFormAvailable
        self.items = []

        self.generateItems(buttonViewDataState)
    }

    func update(navigationState: NavigationState,
                rttState: RttState,
                visibilityState: VisibilityState,
                buttonViewDataState: ButtonViewDataState) {
        isDisplayed = visibilityState.currentStatus == .visible && navigationState.moreOptionsVisible

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
