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

    private let compositeViewModelFactory: CompositeViewModelFactory

    init(compositeViewModelFactory: CompositeViewModelFactory,
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

    func sortedParticipants() -> [ParticipantsListCellViewModel] {
        // alphabetical order
        return ([localParticipantsListCellViewModel] + participantsList).sorted {
            let name = $0.displayName.trimmingCharacters(in: .whitespaces).isEmpty ?
                StringConstants.defaultEmptyName : $0.displayName
            let nextName = $1.displayName.trimmingCharacters(in: .whitespaces).isEmpty ?
                StringConstants.defaultEmptyName : $1.displayName
            return name.localizedCaseInsensitiveCompare(nextName) == .orderedAscending
        }
    }
}
