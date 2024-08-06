//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class BannerViewModel: ObservableObject {

    @Published var isBannerDisplayed = false
    var bannerTextViewModel: BannerTextViewModel

    private let dispatch: ActionDispatch

    var dismissButtonViewModel: IconButtonViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol, dispatchAction: @escaping ActionDispatch) {
        self.dispatch = dispatchAction
        self.bannerTextViewModel = compositeViewModelFactory.makeBannerTextViewModel()
        self.dismissButtonViewModel = compositeViewModelFactory.makeIconButtonViewModel(
            iconName: .dismiss,
            buttonType: .dismissButton,
            isDisabled: false) { [weak self] in
                guard let self = self else {
                    return
                }
                self.dismissBanner()
        }
        self.dismissButtonViewModel.update(accessibilityLabel: "Dismiss Banner")
        self.dismissButtonViewModel.update(accessibilityHint: "Dismisses this notification")
    }

    func update(callingState: CallingState, visibilityState: VisibilityState) {
        let recordingState = callingState.recordingStatus
        let transcriptionState = callingState.transcriptionStatus

        var toDisplayBanner = true
        switch(recordingState, transcriptionState) {
        case (.on, .on):
            bannerTextViewModel.update(bannerInfoType: .recordingAndTranscriptionStarted)
        case (.on, .off):
            bannerTextViewModel.update(bannerInfoType: .recordingStarted)
        case (.on, .stopped):
            bannerTextViewModel.update(bannerInfoType: .transcriptionStoppedStillRecording)
        case (.off, .on):
            bannerTextViewModel.update(bannerInfoType: .transcriptionStarted)
        case (.off, .off):
            bannerTextViewModel.update(bannerInfoType: nil)
            toDisplayBanner = false
        case (.off, .stopped):
            bannerTextViewModel.update(bannerInfoType: .transcriptionStoppedAndSaved)
        case (.stopped, .on):
            bannerTextViewModel.update(bannerInfoType: .recordingStoppedStillTranscribing)
        case (.stopped, .off):
            bannerTextViewModel.update(bannerInfoType: .recordingStopped)
        case (.stopped, .stopped):
            bannerTextViewModel.update(bannerInfoType: .recordingAndTranscriptionStopped)
        }
        isBannerDisplayed = toDisplayBanner
        && !callingState.isRecorcingTranscriptionBannedDismissed
        && visibilityState.currentStatus == VisibilityStatus.visible
    }

    private func dismissBanner() {
        dispatch(.callingAction(.dismissRecordingTranscriptionBannedUpdated(isDismissed: true)))
    }
}
