//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

class CaptionsRttInfoViewModel: ObservableObject {
    @Published var displayData = [CaptionsRttRecord]()
    @Published var captionsManager: CaptionsRttDataManager
    @Published var isCaptionsDisplayed = false
    @Published var isRttDisplayed = false
    @Published var isRttAvailable = false
    @Published var isLoading = false
    @Published var isDisplayed = false
    @Published var shouldExpand = false
    var loadingMessage = ""
    var rttInfoMessage = ""
    let localizationProvider: LocalizationProviderProtocol
    private let dispatch: ActionDispatch
    private let captionsOptions: CaptionsOptions
    var title: String
    var endIcon: CompositeIcon?
    var endIconAction: (() -> Void)?
    var textBoxHint: String?
    var endIconAccessibilityValue: String?
    var expandIconAccessibilityValue: String?
    var collapseIconAccessibilityValue: String?
    private var hasInsertedRttInfo = false

    init(state: AppState,
         captionsManager: CaptionsRttDataManager,
         captionsOptions: CaptionsOptions,
         dispatch: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        self.captionsManager = captionsManager
        self.localizationProvider = localizationProvider
        loadingMessage = localizationProvider.getLocalizedString(LocalizationKey.captionsStartingCaptions)
        rttInfoMessage = localizationProvider.getLocalizedString(LocalizationKey.rttWarningMessage)
        self.dispatch = dispatch
        self.captionsOptions = captionsOptions
        self.endIcon = nil
        self.endIconAction = nil
        self.endIconAccessibilityValue = nil
        self.title = ""
        self.textBoxHint = nil
        bindCaptionsUpdates()
        setupItems(state: state)
    }

    private func bindCaptionsUpdates() {
        captionsManager.$captionsRttData
            .receive(on: DispatchQueue.main)
            .assign(to: &$displayData)
    }

    private func setupItems(state: AppState) {
        if state.rttState.isRttOn && state.captionsState.isCaptionsOn {
            title = localizationProvider.getLocalizedString(.rttCaptionsListTitle)
        } else if isRttDisplayed {
            title = localizationProvider.getLocalizedString(.rttListTitle)
        } else {
            title = localizationProvider.getLocalizedString(.captionsListTitle)
        }
        endIcon = state.captionsState.isCaptionsOn ?
        CompositeIcon.closeCaptions : CompositeIcon.closeCaptionsOff

        let language = captionsOptions.spokenLanguage?.lowercased() ?? ""
        endIconAction = {
            if state.captionsState.isCaptionsOn {
                self.dispatch(.captionsAction(.turnOffCaptions))
            } else {
                self.dispatch(.captionsAction(.turnOnCaptions(language: language)))
            }
        }
        textBoxHint = localizationProvider.getLocalizedString(.rttTextBoxHint)
        endIconAccessibilityValue = {
            if state.captionsState.isCaptionsOn {
                localizationProvider.getLocalizedString(.captionsTurnOffCaptions)
            } else {
                localizationProvider.getLocalizedString(.captionsTurnOnCaptions)
            }
        }()
        expandIconAccessibilityValue = localizationProvider.getLocalizedString(.maximizeCaptionsRtt)
        collapseIconAccessibilityValue = localizationProvider.getLocalizedString(.minimizeCaptionsRtt)
    }

    func commitMessage(_ message: String, _ isFinal: Bool) {
        dispatch(.rttAction(.sendRtt(message: message, isFinal: isFinal)))
    }

    func updateLayoutHelight(_ shouldMaximize: Bool) {
        dispatch(.rttAction(.updateMaximized(isMaximized: shouldMaximize)))
    }

    func update(state: AppState) {
        self.isCaptionsDisplayed = state.captionsState.isCaptionsOn
        && state.captionsState.errors != .captionsFailedToStart
        && !isRttDisplayed
        self.isLoading = isCaptionsDisplayed && !state.captionsState.isStarted
        self.isRttDisplayed = state.rttState.isRttOn && !isCaptionsDisplayed
        setupItems(state: state)
        self.shouldExpand = state.rttState.isMaximized
        self.isRttAvailable = state.rttState.isRttOn
        self.isDisplayed = isCaptionsDisplayed || isRttDisplayed
    }
}
