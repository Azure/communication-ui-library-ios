//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
class CaptionsLanguageListViewModel: ObservableObject {
    @Published var languageList: [CaptionsLanguageListCellViewModel] = []

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

    func update(localUserState: LocalUserState,
                captionsState: CaptionsState) {
    }
}
