//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation

class MoreCallOptionsListViewModel {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    @Published var isShareActivityDisplayed: Bool = false

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
    }

    func getListItemsViewModels() -> [MoreCallOptionsListCellViewModel] {
        let shareDiagnosticsInfoModel = compositeViewModelFactory.makeMoreCallOptionsListCellViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo)) { [weak self] in
                self?.isShareActivityDisplayed = true
        }
        return [shareDiagnosticsInfoModel]
    }
}
