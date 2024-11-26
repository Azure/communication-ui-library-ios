//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class CaptionsListViewModel: ObservableObject {
    @Published private var isToggleEnabled = false
    @Published var items: [BaseDrawerItemViewModel] = []

    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let showCaptionsLanguage: () -> Void
    private let showSpokenLanguage: () -> Void
    private let showRttViewAction: () -> Void
    private let dispatch: ActionDispatch
    private let captionsOptions: CaptionsOptions
    var isDisplayed: Bool
    private let isRttAvailable: Bool
    private var isRttEnabled: Bool
    let title: String?
    let backButtonAction: () -> Void

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         captionsOptions: CaptionsOptions,
         state: AppState,
         dispatchAction: @escaping ActionDispatch,
         buttonActions: ButtonActions,
         isRttAvailable: Bool,
         isDisplayed: Bool
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.dispatch = dispatchAction
        self.showSpokenLanguage = buttonActions.showSpokenLanguage ?? { }
        self.showCaptionsLanguage = buttonActions.showCaptionsLanguage ?? { }
        self.isDisplayed = isDisplayed
        self.isToggleEnabled = state.captionsState.isStarted
        self.captionsOptions = captionsOptions
        self.isRttAvailable = isRttAvailable
        self.isRttEnabled = false
        self.showRttViewAction = buttonActions.showRttView ?? { }
        self.title = localizationProvider.getLocalizedString(.rttCaptionsListTitle)
        self.backButtonAction = {
            dispatchAction(.showMoreOptions)
        }

        setupItems(state: state)
        updateCaptionsOptions(state: state)
    }

    private func updateCaptionsOptions(state: AppState) {
        if captionsOptions.captionsOn &&
            !state.captionsState.isStarted &&
            state.callingState.status == .connected &&
            !isToggleEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.toggleCaptions(newValue: true)
            }
        }
    }

    private func setupItems(state: AppState) {
        items.removeAll()
        let buttonViewDataState = state.buttonViewDataState

        if buttonViewDataState.liveCaptionsToggleButton?.visible ?? true {
            let enableCaptionsInfoModel = compositeViewModelFactory.makeToggleListItemViewModel(
                title: localizationProvider.getLocalizedString(.captionsListTitle),
                isToggleOn: Binding(get: { self.isToggleEnabled }, set: toggleCaptions),
                showToggle: true,
                accessibilityIdentifier: "",
                startIcon: .closeCaptions,
                isEnabled: buttonViewDataState.liveCaptionsToggleButton?.enabled ?? true,
                action: {}
            )
            items.append(enableCaptionsInfoModel)
        }

        if buttonViewDataState.spokenLanguageButton?.visible ?? true {
            let spokenLanguageInfoModel = compositeViewModelFactory.makeLanguageListItemViewModel(
                title: localizationProvider.getLocalizedString(.captionsSpokenLanguage),
                subtitle: languageDisplayName(for: state.captionsState.spokenLanguage ?? "en-US"),
                accessibilityIdentifier: "",
                startIcon: .personVoice,
                endIcon: .rightChevron,
                isEnabled: self.isToggleEnabled && buttonViewDataState.spokenLanguageButton?.enabled ?? true,
                action: self.isToggleEnabled ? showSpokenLanguage : {})
            items.append(spokenLanguageInfoModel)
        }

        if state.captionsState.activeType == .teams && buttonViewDataState.captionsLanguageButton?.visible ?? true {
            let captionsLanguageInfoModel = compositeViewModelFactory.makeLanguageListItemViewModel(
                title: localizationProvider.getLocalizedString(.captionsCaptionLanguage),
                subtitle: languageDisplayName(for: state.captionsState.captionLanguage ?? "en"),
                accessibilityIdentifier: "",
                startIcon: .localLanguage,
                endIcon: .rightChevron,
                isEnabled: self.isToggleEnabled && buttonViewDataState.captionsLanguageButton?.enabled ?? true,
                action: self.isToggleEnabled ? showCaptionsLanguage : {})

            items.append(captionsLanguageInfoModel)
        }

        if isRttAvailable {
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
                deny: { self.dispatch(.hideDrawer) }

            )
            items.append(rttInfoModel)
        }
    }
    func update(state: AppState) {
        isDisplayed = state.navigationState.captionsViewVisible
        isToggleEnabled = state.captionsState.isStarted
        isRttEnabled = state.rttState.isRttOn
        setupItems(state: state)
    }

    private func toggleCaptions(newValue: Bool) {
        isToggleEnabled = newValue
        let language = captionsOptions.spokenLanguage?.lowercased() ?? ""
        if isToggleEnabled {
            dispatch(.captionsAction(.turnOnCaptions(language: language)))
        } else {
            dispatch(.captionsAction(.turnOffCaptions))
        }
    }

    private func languageDisplayName(for code: String) -> String {
        let locale = Locale(identifier: code)
        return Locale.current.localizedString(forIdentifier: locale.identifier) ?? ""
    }
}
