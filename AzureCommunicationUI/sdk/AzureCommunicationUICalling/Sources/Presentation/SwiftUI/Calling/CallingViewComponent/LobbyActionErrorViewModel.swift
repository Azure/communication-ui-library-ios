//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class LobbyActionErrorViewModel: ObservableObject {
    @Published var accessibilityLabel: String
    @Published var title: String
    @Published var isDisplayed: Bool = false
    @Published var isVoiceOverEnabled: Bool = false

    private let logger: Logger
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let localizationProvider: LocalizationProviderProtocol
    private var lastErrorTimestamp: Date?

    var dismissButtonViewModel: IconButtonViewModel!

    var isPad: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         logger: Logger,
         localUserState: LocalUserState,
         localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         dispatchAction: @escaping ActionDispatch) {
        self.logger = logger
        self.accessibilityProvider = accessibilityProvider
        self.localizationProvider = localizationProvider
        let title = ""
        self.title = title
        self.accessibilityLabel = title

        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .dismiss,
            buttonType: .infoButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                dispatchAction(.remoteParticipantsAction(.lobbyError(errorCode: nil)))
        }
        self.dismissButtonViewModel.accessibilityLabel = self.localizationProvider.getLocalizedString(
            .lobbyActionErrorDismiss)
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState,
                callingState: CallingState) {
        let mayDisplay = !isHoldingOrInLobby(callingState: callingState)

        guard mayDisplay else {
            isDisplayed = false
            return
        }

        var isDisplayed: Bool = false
        var lastErrorTimestamp: Date?
        if let lobbyError = remoteParticipantsState.lobbyError,
           self.lastErrorTimestamp != lobbyError.errorTimeStamp {
            isDisplayed = true
            lastErrorTimestamp = lobbyError.errorTimeStamp

            let title = getErrorText(lobbyError.lobbyErrorCode)
            self.title = title
            self.accessibilityLabel = title
        }

        if self.isDisplayed != isDisplayed {
            self.isDisplayed = isDisplayed
        }
        if self.lastErrorTimestamp != lastErrorTimestamp {
            self.lastErrorTimestamp = lastErrorTimestamp
        }
    }

    private func getErrorText(_ lobbyErrorCode: LobbyErrorCode) -> String {

        var localizationKey: LocalizationKey

        switch lobbyErrorCode {
        case .lobbyConversationTypeNotSupported:
            localizationKey = .lobbyActionErrorConversationTypeNotSupported
        case .lobbyDisabledByConfigurations:
            localizationKey = .lobbyActionErrorLobbyDisabledByConfigurations
        case .lobbyMeetingRoleNotAllowed:
            localizationKey = .lobbyActionErrorMeetingRoleNotAllowed
        case .removeParticipantOperationFailure:
            localizationKey = .lobbyActionErrorParticipantOperationFailure
        case .unknownError:
            localizationKey = .lobbyActionUnknownError
        }
        return localizationProvider.getLocalizedString(localizationKey)
    }

    private func isHoldingOrInLobby(callingState: CallingState) -> Bool {
        guard callingState.status == .inLobby || callingState.status == .localHold else {
            return false
        }
        if isDisplayed {
            isDisplayed = false
        }

        return true
    }
}
