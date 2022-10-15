//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation

struct CallInfoListViewModel {
    let headerName: String?

    private let localizationProvider: LocalizationProviderProtocol
    private let diagnosticsManager: DiagnosticsManagerProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         diagnosticsManager: DiagnosticsManagerProtocol) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider
        self.diagnosticsManager = diagnosticsManager
        headerName = localizationProvider.getLocalizedString(.callInfoDrawerHeader)
    }

    func getListItemsViewModels() -> [CallInfoListCellViewModel] {
        let callIdModel = compositeViewModelFactory.makeCallInfoListCellViewModel(
            icon: .info,
            title: localizationProvider.getLocalizedString(.callId),
            detailTitle: diagnosticsManager.callId, action: nil)
        let copyCallIdModel = compositeViewModelFactory.makeCallInfoListCellViewModel(
            icon: .copy,
            title: localizationProvider.getLocalizedString(.copyCallInfo),
            detailTitle: nil) {
            // add action
        }
        return [callIdModel, copyCallIdModel]
    }
}
