//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CaptionsRttInfoViewModel: ObservableObject {
    @Published var captionsData = [CallCompositeCaptionsData]()
    @Published var isCaptionsDisplayed = false
    @Published var isRttDisplayed = false
    @Published var isRttAvailable = false
    @Published var isLoading = false
    var loadingMessage = ""
    private var captionsManager: CaptionsViewManager
    private let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch
    private let captionsOptions: CaptionsOptions
    var title: String
    var endIcon: CompositeIcon?
    var endIconAction: (() -> Void)?
    var textBoxHint: String?

    init(state: AppState,
         captionsManager: CaptionsViewManager,
         captionsOptions: CaptionsOptions,
         dispatch: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        self.captionsManager = captionsManager
        self.localizationProvider = localizationProvider
        loadingMessage = localizationProvider.getLocalizedString(LocalizationKey.captionsStartingCaptions)
        self.dispatch = dispatch
        self.captionsOptions = captionsOptions
        self.endIcon = nil
        self.endIconAction = nil
        self.title = ""
        self.textBoxHint = nil
        bindCaptionsUpdates()
        setupItems(state: state)
    }

    private func bindCaptionsUpdates() {
        captionsManager.$captionData
            .receive(on: DispatchQueue.main)
            .assign(to: &$captionsData)
    }

    private func setupItems(state: AppState) {
        title = isRttDisplayed ? localizationProvider.getLocalizedString(.rttListTitile) :
        localizationProvider.getLocalizedString(.captionsListTitile)
        let closeCaptionsIcon = state.captionsState.isCaptionsOn ?
        CompositeIcon.closeCaptions : CompositeIcon.closeCaptionsOff

        let rttIcon = CompositeIcon.rtt
        endIcon = isRttDisplayed ? closeCaptionsIcon : rttIcon
        let buttonViewDataState = state.buttonViewDataState
        let language = captionsOptions.spokenLanguage?.lowercased() ?? ""
        endIconAction = {
            if self.isRttDisplayed {
                if state.captionsState.isCaptionsOn {
                    self.dispatch(.captionsAction(.turnOffCaptions))
                } else {
                    self.dispatch(.captionsAction(.turnOnCaptions(language: language)))
                }
            } else {
                self.dispatch(.rttAction(.turnOnRtt))
            }
        }
        textBoxHint = localizationProvider.getLocalizedString(.rttTextBoxHint)
    }

    func commitText(_ message: String) {
        dispatch(.rttAction(.sendRtt(message: message, resultType: .partial)))
    }

    func update(state: AppState) {
        self.isCaptionsDisplayed = state.captionsState.isCaptionsOn
        && state.captionsState.errors != .captionsFailedToStart
        && !isRttDisplayed
        self.isLoading = isCaptionsDisplayed && !state.captionsState.isStarted
        self.isRttDisplayed = state.rttState.isRttOn && !isCaptionsDisplayed
        setupItems(state: state)
        isRttAvailable = state.rttState.isRttOn
    }
}
