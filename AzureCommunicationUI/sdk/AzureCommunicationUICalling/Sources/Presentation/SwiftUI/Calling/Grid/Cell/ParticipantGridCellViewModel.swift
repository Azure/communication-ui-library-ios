//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

struct ParticipantVideoViewInfoModel {
    let videoStreamType: VideoStreamInfoModel.MediaStreamType?
    let videoStreamId: String?
}

class ParticipantGridCellViewModel: ObservableObject, Identifiable {
    private let localizationProvider: LocalizationProviderProtocol
    private let accessibilityProvider: AccessibilityProviderProtocol
    private let captionsRttDataManager: CaptionsAndRttViewManager

    let id = UUID()

    @Published var videoViewModel: ParticipantVideoViewInfoModel?
    @Published var accessibilityLabel: String = ""
    @Published var displayName: String?
    @Published var avatarDisplayName: String?
    @Published var isSpeaking: Bool
    @Published var isMuted: Bool
    @Published var isHold: Bool
    @Published var participantIdentifier: String
    @Published var displayData = [CallCompositeRttCaptionsDisplayData]()

    private var isScreenSharing = false
    private var participantName: String
    private var renderDisplayName: String?
    private var isCameraEnabled: Bool
    private var participantStatus: ParticipantStatus?
    private var callType: CompositeCallType
    private var subscriptions = Set<AnyCancellable>()
    private var participantModel: ParticipantInfoModel?

    init(localizationProvider: LocalizationProviderProtocol,
         accessibilityProvider: AccessibilityProviderProtocol,
         participantModel: ParticipantInfoModel,
         isCameraEnabled: Bool,
         captionsRttManager: CaptionsAndRttViewManager,
         callType: CompositeCallType) {
        self.localizationProvider = localizationProvider
        self.accessibilityProvider = accessibilityProvider
        self.participantStatus = participantModel.status
        self.captionsRttDataManager = captionsRttManager
        self.callType = callType
        self.participantModel = participantModel
        let isDisplayConnecting = ParticipantGridCellViewModel.isOutgoingCallDialingInProgress(
            callType: callType,
            participantStatus: participantModel.status)
        if isDisplayConnecting {
            self.participantName = localizationProvider.getLocalizedString(LocalizationKey.callingCallMessage)
            self.displayName = self.participantName
        } else {
            self.participantName = participantModel.displayName
            self.displayName = participantModel.displayName
        }
        self.avatarDisplayName = participantModel.displayName
        self.isSpeaking = participantModel.isSpeaking
        self.isHold = participantModel.status == .hold
        self.participantIdentifier = participantModel.userIdentifier
        self.isMuted = participantModel.isMuted && participantModel.status == .connected
        self.isCameraEnabled = isCameraEnabled
        self.videoViewModel = getDisplayingVideoStreamModel(participantModel)
        self.accessibilityLabel = getAccessibilityLabel(participantModel: participantModel)
        bindCaptionsUpdates()
    }

    private func bindCaptionsUpdates() {
        captionsRttDataManager.$captionsRttData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard let self = self else {
                    return
                }
                self.displayData = data
                self.updateIsSpeaking(with: data)
            }
            .store(in: &subscriptions)
    }

    private func updateIsSpeaking(with data: [CallCompositeRttCaptionsDisplayData]) {
        DispatchQueue.main.async {
            // Check for any non-final RTT message matching the participant's userIdentifier
            let hasActiveRtt = data.contains { rttData in
                rttData.captionsRttType == .rtt &&
                !rttData.isFinal &&
                rttData.displayRawId == self.participantIdentifier
            }

            // Update isSpeaking based on RTT data and participant's speaking status
            self.isSpeaking = hasActiveRtt || self.isSpeakingFromParticipantModel

            // If no active RTT and participant is not speaking, reset isSpeaking
            if !hasActiveRtt && !self.isSpeakingFromParticipantModel {
                self.isSpeaking = false
            }
        }
    }

    private var isSpeakingFromParticipantModel: Bool {
        return participantModel?.isSpeaking ?? false
    }

    func update(participantModel: ParticipantInfoModel) {
        self.participantIdentifier = participantModel.userIdentifier
        let videoViewModel = getDisplayingVideoStreamModel(participantModel)
        if self.videoViewModel?.videoStreamId != videoViewModel.videoStreamId ||
            self.videoViewModel?.videoStreamType != videoViewModel.videoStreamType {
            let newIsScreenSharing = videoViewModel.videoStreamType == .screenSharing
            if newIsScreenSharing {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.screenshareStartAccessibilityLabel))
            } else if self.isScreenSharing && !newIsScreenSharing {
                accessibilityProvider.postQueuedAnnouncement(
                    localizationProvider.getLocalizedString(.screenshareEndAccessibilityLabel))
            }
            self.isScreenSharing = newIsScreenSharing
            self.videoViewModel = ParticipantVideoViewInfoModel(videoStreamType: videoViewModel.videoStreamType,
                                                 videoStreamId: videoViewModel.videoStreamId)
        }

        if self.participantName != participantModel.displayName ||
            self.isMuted != participantModel.isMuted ||
            self.isSpeaking != participantModel.isSpeaking ||
            self.isCameraEnabled != participantModel.cameraVideoStreamModel?.videoStreamIdentifier.isEmpty ||
            self.isHold != (participantModel.status == .hold) {
            self.accessibilityLabel = getAccessibilityLabel(participantModel: participantModel)
        }

        if self.participantStatus != participantModel.status {
            self.participantStatus = participantModel.status
            updateParticipantNameIfNeeded(with: renderDisplayName)
            self.isMuted = participantModel.isMuted && participantModel.status == .connected
        }
        if self.participantName != participantModel.displayName {
            self.participantName = participantModel.displayName
            updateParticipantNameIfNeeded(with: renderDisplayName)
        }

        if self.isSpeaking != participantModel.isSpeaking {
            self.isSpeaking = participantModel.isSpeaking
        }

        if self.isMuted != participantModel.isMuted {
            self.isMuted = participantModel.isMuted && participantModel.status == .connected
        }

        let isOnHold = participantModel.status == .hold

        if self.isHold != isOnHold {
            self.isHold = isOnHold
            postParticipantStatusAccessibilityAnnouncements(isHold: self.isHold, participantModel: participantModel)
        }
    }

    func updateParticipantNameIfNeeded(with renderDisplayName: String?) {
        let isDisplayConnecting = ParticipantGridCellViewModel.isOutgoingCallDialingInProgress(
            callType: callType,
            participantStatus: participantStatus)
        if isDisplayConnecting {
            self.participantName = localizationProvider.getLocalizedString(LocalizationKey.callingCallMessage)
            self.displayName = self.participantName
            self.renderDisplayName = renderDisplayName
            self.avatarDisplayName = renderDisplayName
            return
        }
        self.renderDisplayName = renderDisplayName
        guard renderDisplayName != displayName else {
            return
        }

        let name: String
        if let renderDisplayName = renderDisplayName {
            let isRendererNameEmpty = renderDisplayName.trimmingCharacters(in: .whitespaces).isEmpty
            name = isRendererNameEmpty ? participantName : renderDisplayName
        } else {
            name = participantName
        }
        self.displayName = name
        self.avatarDisplayName = displayName
    }

    func getOnHoldString() -> String {
        localizationProvider.getLocalizedString(.onHold)
    }

    private func getAccessibilityLabel(participantModel: ParticipantInfoModel) -> String {
        let status = participantModel.status == .hold ? getOnHoldString() :
        localizationProvider.getLocalizedString(participantModel.isSpeaking ? .speaking :
                                                    participantModel.isMuted ? .muted : .unmuted)

        let videoStatus = (videoViewModel?.videoStreamId?.isEmpty ?? true) ?
        localizationProvider.getLocalizedString(.videoOff) :
        localizationProvider.getLocalizedString(.videoOn)
        return localizationProvider.getLocalizedString(.participantInformationAccessibilityLable,
                                                       participantModel.displayName, status, videoStatus)
    }

    private func getDisplayingVideoStreamModel(_ participantModel: ParticipantInfoModel)
    -> ParticipantVideoViewInfoModel {
        let screenShareVideoStreamIdentifier = participantModel.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = isCameraEnabled ?
        participantModel.cameraVideoStreamModel?.videoStreamIdentifier :
        nil

        let screenShareVideoStreamType = participantModel.screenShareVideoStreamModel?.mediaStreamType
        let cameraVideoStreamType = participantModel.cameraVideoStreamModel?.mediaStreamType
        return screenShareVideoStreamIdentifier != nil ?
        ParticipantVideoViewInfoModel(videoStreamType: screenShareVideoStreamType,
                                      videoStreamId: screenShareVideoStreamIdentifier) :
        ParticipantVideoViewInfoModel(videoStreamType: cameraVideoStreamType,
                                      videoStreamId: cameraVideoStreamIdentifier)
    }

    private static func isOutgoingCallDialingInProgress(callType: CompositeCallType,
                                                        participantStatus: ParticipantStatus?) -> Bool {
        return callType == .oneToNOutgoing &&
               (participantStatus == nil || participantStatus == .connecting || participantStatus == .ringing)
    }

    private func postParticipantStatusAccessibilityAnnouncements(isHold: Bool, participantModel: ParticipantInfoModel) {
        let holdResumeAccessibilityAnnouncement = isHold ?
            localizationProvider.getLocalizedString(.onHoldAccessibilityLabel, participantModel.displayName) :
            localizationProvider.getLocalizedString(.participantResumeAccessibilityLabel, participantModel.displayName)
        accessibilityProvider.postQueuedAnnouncement(holdResumeAccessibilityAnnouncement)
    }
}
