//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

protocol UpdatableOptionsManagerProtocol {
    var setupScreenOptions: SetupScreenOptions? { get }
    var callScreenOptions: CallScreenOptions? { get }
}

class UpdatableOptionsManager: UpdatableOptionsManagerProtocol {
    private let store: Store<AppState, Action>
    private var subscriptions = Set<AnyCancellable>()

    let setupScreenOptions: SetupScreenOptions?
    let callScreenOptions: CallScreenOptions?

    // swiftlint:disable function_body_length
    init(store: Store<AppState, Action>,
         setupScreenOptions: SetupScreenOptions?,
         callScreenOptions: CallScreenOptions?
    ) {
        self.store = store
        self.callScreenOptions = callScreenOptions
        self.setupScreenOptions = setupScreenOptions

        /* <TIMER_TITLE_FEATURE> */
        callScreenOptions?.headerViewData?.$title
            .sink { [weak self] newTitle in
                self?.store.dispatch(action: .callScreenInfoHeaderAction(.updateTitle(title: newTitle)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.headerViewData?.$subtitle
            .sink { [weak self] newSubtitle in
                self?.store.dispatch(action: .callScreenInfoHeaderAction(.updateSubtitle(subtitle: newSubtitle)))
            }
            .store(in: &subscriptions)
        /* </TIMER_TITLE_FEATURE> */

        setupScreenOptions?.audioDeviceButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .setupScreenAudioDeviceButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        setupScreenOptions?.audioDeviceButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .setupScreenAudioDeviceButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        setupScreenOptions?.cameraButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .setupScreenCameraButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        setupScreenOptions?.cameraButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .setupScreenCameraButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        setupScreenOptions?.microphoneButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .setupScreenMicButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        setupScreenOptions?.microphoneButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .setupScreenMicButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.audioDeviceButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenAudioDeviceButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.audioDeviceButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenAudioDeviceButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.cameraButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenCameraButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.cameraButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenCameraButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.microphoneButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenMicButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.microphoneButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenMicButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.reportIssueButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenReportIssueButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.reportIssueButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenReportIssueButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.shareDiagnosticsButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenShareDiagnosticsButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.shareDiagnosticsButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenShareDiagnosticsButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.liveCaptionsButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenLiveCaptionsButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.liveCaptionsButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenLiveCaptionsButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.liveCaptionsToggleButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenLiveCaptionsToggleButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.liveCaptionsToggleButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenLiveCaptionsToggleButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.spokenLanguageButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenSpokenLanguageButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.spokenLanguageButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenSpokenLanguageButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.captionsLanguageButton?.$visible
            .sink { [weak self] visible in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenCaptionsLanguageButtonIsVisibleUpdated(visible: visible)))
            }
            .store(in: &subscriptions)
        callScreenOptions?.controlBarOptions?.captionsLanguageButton?.$enabled
            .sink { [weak self] enabled in
                self?.store.dispatch(action: .buttonViewDataAction(
                    .callScreenCaptionsLanguageButtonIsEnabledUpdated(enabled: enabled)))
            }
            .store(in: &subscriptions)

        callScreenOptions?.controlBarOptions?.customButtons.forEach { button in
            button.$enabled
                .sink { [weak self] enabled in
                    self?.store.dispatch(action: .buttonViewDataAction(
                        .callScreenCaptionsLanguageButtonIsEnabledUpdated(enabled: enabled)))
                }
                .store(in: &subscriptions)
        }
    }
    // swiftlint:enable function_body_length
}
