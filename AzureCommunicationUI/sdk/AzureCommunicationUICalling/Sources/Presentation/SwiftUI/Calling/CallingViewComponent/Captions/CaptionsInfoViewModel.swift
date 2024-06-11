//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class CaptionsInfoViewModel: ObservableObject {
    @Published var captionsList: [CaptionsLanguageListViewModel] = []

    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    private let dispatch: ActionDispatch

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         dispatchAction: @escaping ActionDispatch,
         localizationProvider: LocalizationProviderProtocol) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.dispatch = dispatchAction
        self.localizationProvider = localizationProvider
    }

    func update(remoteParticipantsState: CaptionsState) {
//        captionsList = remoteParticipantsState.participantInfoList
//            .filter({ participant in
//                participant.status != .disconnected
//            })
//            .map {
//                compositeViewModelFactory.makeCaptionsInfoCellViewModel(participantInfoModel: $0)
//            }
    }
}
