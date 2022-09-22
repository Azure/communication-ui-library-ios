//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class DraggablePIPViewModel: ObservableObject {
    let isRightToLeft: Bool
    let localVideoViewModel: LocalVideoViewModel

    @Published var videoViewModel: ParticipantVideoViewInfoModel?
    @Published var displayedParticipantInfoModel: ParticipantInfoModel?
    @Published var displayName: String? = ""
    private var participantName: String = ""
    private var renderDisplayName: String?

    private var lastUpdateTimeStamp = Date()

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        isRightToLeft = localizationProvider.isRightToLeft
        localVideoViewModel = compositeViewModelFactory.makeLocalVideoViewModel(dispatchAction: dispatchAction)
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState) {
        localVideoViewModel.update(localUserState: localUserState)
        updateRemoteParticipantStateIfNeeded(remoteParticipantsState)
    }

    private func updateRemoteParticipantStateIfNeeded(_ state: RemoteParticipantsState) {
        guard lastUpdateTimeStamp != state.lastUpdateTimeStamp else {
            return
        }
        lastUpdateTimeStamp = state.lastUpdateTimeStamp

        let remoteParticipants = state.participantInfoList
        if let presentingParticipant = remoteParticipants.first(where: { $0.screenShareVideoStreamModel != nil }) {
            displayedParticipantInfoModel = presentingParticipant
        } else {
            let sortedInfoList = remoteParticipants.sorted(by: {
                $0.recentSpeakingStamp.compare($1.recentSpeakingStamp) == .orderedDescending
            })
            displayedParticipantInfoModel = sortedInfoList.first
        }
        if let infoModel = displayedParticipantInfoModel {
            videoViewModel = getDisplayingVideoStreamModel(infoModel)
        } else {
            videoViewModel = nil
        }

        if let displayedParticipantInfoModel = displayedParticipantInfoModel,
           self.participantName != displayedParticipantInfoModel.displayName {
            self.participantName = displayedParticipantInfoModel.displayName
            updateParticipantNameIfNeeded(with: renderDisplayName)
        }
    }

    private func getDisplayingVideoStreamModel(_ participantModel: ParticipantInfoModel)
    -> ParticipantVideoViewInfoModel {
        let screenShareVideoStreamIdentifier = participantModel.screenShareVideoStreamModel?.videoStreamIdentifier
        let cameraVideoStreamIdentifier = participantModel.cameraVideoStreamModel?.videoStreamIdentifier
        let screenShareVideoStreamType = participantModel.screenShareVideoStreamModel?.mediaStreamType
        let cameraVideoStreamType = participantModel.cameraVideoStreamModel?.mediaStreamType

        return screenShareVideoStreamIdentifier != nil ?
        ParticipantVideoViewInfoModel(videoStreamType: screenShareVideoStreamType,
                                      videoStreamId: screenShareVideoStreamIdentifier) :
        ParticipantVideoViewInfoModel(videoStreamType: cameraVideoStreamType,
                                      videoStreamId: cameraVideoStreamIdentifier)
    }

    func updateParticipantNameIfNeeded(with renderDisplayName: String?) {
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
        displayName = name
    }
}
