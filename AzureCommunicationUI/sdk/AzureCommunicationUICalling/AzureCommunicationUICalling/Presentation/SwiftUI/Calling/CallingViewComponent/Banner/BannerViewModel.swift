//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class BannerViewModel: ObservableObject {
    enum FeatureStatus: Equatable {
        case on
        case off
        case stopped
    }

    @Published var isBannerDisplayed: Bool = false
    var bannerTextViewModel: BannerTextViewModel

    private var callingState = CallingState()
    private var recordingState: FeatureStatus = .off
    private var transcriptionState: FeatureStatus = .off

    var dismissButtonViewModel: IconButtonViewModel!

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol) {
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

    func update(callingState: CallingState) {
        if self.callingState.isRecordingActive != callingState.isRecordingActive ||
            self.callingState.isTranscriptionActive != callingState.isTranscriptionActive {
            self.updateBanner(callingState: callingState)
            self.callingState = callingState
        }
    }

    private func updateBanner(callingState: CallingState) {
        if callingState.isRecordingActive {
            recordingState = .on
        } else {
            recordingState = recordingState == .on ? .stopped : recordingState
        }
        if callingState.isTranscriptionActive {
            transcriptionState = .on
        } else {
            transcriptionState = transcriptionState == .on ? .stopped : transcriptionState
        }
        displayBanner(recordingState: recordingState, transcriptionState: transcriptionState)
        if recordingState == .stopped,
           transcriptionState == .stopped {
            recordingState = .off
            transcriptionState = .off
        }
    }

    private func displayBanner(recordingState: FeatureStatus,
                               transcriptionState: FeatureStatus) {
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
    }

    private func dismissBanner() {
        isBannerDisplayed = false
        if recordingState == .stopped {
            recordingState = .off
        }
        if transcriptionState == .stopped {
            transcriptionState = .off
        }
        bannerTextViewModel.update(bannerInfoType: nil)
    }
}
