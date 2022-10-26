//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine

class MoreCallOptionsListViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    let items: [MoreCallOptionsListCellViewModel]

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider

        let shareDiagnosticsInfoModel = compositeViewModelFactory.makeMoreCallOptionsListCellViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            action: showSharingViewAction)
        items = [shareDiagnosticsInfoModel]
    }
}
