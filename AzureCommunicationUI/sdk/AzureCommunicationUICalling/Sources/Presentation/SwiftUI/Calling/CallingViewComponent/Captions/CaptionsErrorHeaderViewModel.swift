//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class CaptionsErrorHeaderViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var title: String
    @Published var isDisplayed = false
    @Published var isVoiceOverEnabled = false

    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol

    var dismissButtonViewModel: IconButtonViewModel!

    var isPad = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.logger = logger
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.accessibilityLabel = ""
        self.title = ""

        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .dismiss,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard self != nil else {
                    return
                }
                dispatchAction(.captionsAction(.error(errors: .none)))
        }
        self.dismissButtonViewModel.accessibilityLabel =
        localizationProvider.getLocalizedString(.lobbyActionErrorDismiss)
    }

    func update(captionsState: CaptionsState, callingState: CallingState) {
        isDisplayed = captionsState.errors != .none && callingState.status == .connected

        // Clearing title and accessibility label if there are no errors
        if captionsState.errors == .none {
            title = ""
            accessibilityLabel = ""
        } else {
            // There is an error, update the title and accessibility label
            let errorText = getErrorText(captionsState.errors)
            title = errorText
            accessibilityLabel = errorText
        }
    }

    private func getErrorText(_ captionsErrorCode: CallCompositeCaptionsErrors) -> String {

        var localizationKey: LocalizationKey

        switch captionsErrorCode {
        case .none:
            return ""
        case .captionsFailedToStart:
            localizationKey = .captionsStartCaptionsError
        case .captionsFailedToStop:
            localizationKey = .captionsStopCaptionsError
        case .captionsFailedToSetSpokenLanguage:
            localizationKey = .captionsChangeSpokenLanguageError
        case .captionsFailedToSetCaptionLanguage:
            localizationKey = .captionsChangeCaptionsLanguageError
        }
        return localizationProvider.getLocalizedString(localizationKey)
    }
}
