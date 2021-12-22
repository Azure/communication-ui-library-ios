//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class ParticipantsListViewModel: ObservableObject {

    @Published var participantsList: [ParticipantsListCellViewModel] = []
    @Published var localParticipantsListCellViewModel: ParticipantsListCellViewModel

    let defaultEmptyName: String = "Unnamed Participant"
    var lastUpdateTimeStamp = Date()

    init(localUserState: LocalUserState) {
        localParticipantsListCellViewModel = ParticipantsListCellViewModel(localUserState: localUserState)
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState) {

        if localParticipantsListCellViewModel.isMuted != (localUserState.audioState.operation == .off) {
            localParticipantsListCellViewModel = ParticipantsListCellViewModel(localUserState: localUserState)
        }

        if lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp {
            lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
            participantsList = remoteParticipantsState.participantInfoList.map {
                ParticipantsListCellViewModel(participantInfoModel: $0)
            }
        }
    }

    func sortedParticipants() -> [ParticipantsListCellViewModel] {
        // alphabetical order
        return ([localParticipantsListCellViewModel] + participantsList).sorted {
            let name = $0.displayName.trimmingCharacters(in: .whitespaces).isEmpty ?
                defaultEmptyName : $0.displayName
            let nextName = $1.displayName.trimmingCharacters(in: .whitespaces).isEmpty ?
                defaultEmptyName : $1.displayName
            return name.localizedCaseInsensitiveCompare(nextName) == .orderedAscending
        }
    }
}
