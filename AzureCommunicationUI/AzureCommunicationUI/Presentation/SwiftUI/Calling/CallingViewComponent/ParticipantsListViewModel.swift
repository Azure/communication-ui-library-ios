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
    private let localizationProvider: LocalizationProvider

    init(localUserState: LocalUserState,
         localizationProvider: LocalizationProvider) {
        localParticipantsListCellViewModel = ParticipantsListCellViewModel(localUserState: localUserState,
                                                                           localizationProvider: localizationProvider)
        self.localizationProvider = localizationProvider
    }

    func update(localUserState: LocalUserState,
                remoteParticipantsState: RemoteParticipantsState) {

        if localParticipantsListCellViewModel.isMuted != (localUserState.audioState.operation == .off) {
            localParticipantsListCellViewModel = ParticipantsListCellViewModel(
                localUserState: localUserState,
                localizationProvider: localizationProvider)
        }

        if lastUpdateTimeStamp != remoteParticipantsState.lastUpdateTimeStamp {
            lastUpdateTimeStamp = remoteParticipantsState.lastUpdateTimeStamp
            participantsList = remoteParticipantsState.participantInfoList.map {
                ParticipantsListCellViewModel(participantInfoModel: $0,
                                              localizationProvider: localizationProvider)
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
