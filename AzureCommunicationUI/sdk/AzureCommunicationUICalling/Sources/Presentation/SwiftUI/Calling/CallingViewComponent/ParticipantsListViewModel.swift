//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantsListViewModel: ObservableObject {
    @Published var participantsList: [ParticipantsListCellViewModel] = []
    @Published var localParticipantsListCellViewModel: ParticipantsListCellViewModel
    var lastUpdateTimeStamp = Date()

    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localUserState: LocalUserState) {
        self.compositeViewModelFactory = compositeViewModelFactory
        localParticipantsListCellViewModel =
        compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState) {

        if localParticipantsListCellViewModel.isMuted != (localUserState.audioState.operation == .off) {
            localParticipantsListCellViewModel =
            compositeViewModelFactory.makeLocalParticipantsListCellViewModel(localUserState: localUserState)
        }

        if lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp {
            lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
            participantsList = remoteParticipantsState.participantInfoList.map {
                compositeViewModelFactory.makeParticipantsListCellViewModel(participantInfoModel: $0)
            }
        }
    }

    func sortedParticipants(with avatarManager: AvatarViewManager) -> [ParticipantsListCellViewModel] {
        // alphabetical order
        return ([localParticipantsListCellViewModel] + participantsList).sorted {
            let name = $0.getCellDisplayName(with: $0.getParticipantViewData(from: avatarManager))
            let nextName = $1.getCellDisplayName(with: $1.getParticipantViewData(from: avatarManager))
            return name.localizedCaseInsensitiveCompare(nextName) == .orderedAscending
        }
    }
}
