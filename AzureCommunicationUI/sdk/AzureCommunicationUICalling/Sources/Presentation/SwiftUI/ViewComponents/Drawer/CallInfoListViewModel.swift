//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation

struct MoreCallOptionsListViewModel {
    private let localizationProvider: LocalizationProviderProtocol
    private let diagnosticsManager: DiagnosticsManagerProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         diagnosticsManager: DiagnosticsManagerProtocol) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.diagnosticsManager = diagnosticsManager
    }

    func getListItemsViewModels() -> [MoreCallOptionsListCellViewModel] {
        let shareDiagnosticsInfoModel = compositeViewModelFactory.makeMoreCallOptionsListCellViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo)) {
            // add action
        }
        return [shareDiagnosticsInfoModel]
    }
}
