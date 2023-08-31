//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

class UFDInfoViewModel: ObservableObject {
    @Published private(set) var isDisplayed: Bool = false
    @Published private(set) var title: String = ""
    @Published private(set) var subtitle: String = ""

    private let localizationProvider: LocalizationProviderProtocol

    init(localizationProvider: LocalizationProviderProtocol) {
        self.localizationProvider = localizationProvider
    }

    var dismissContent: String {
        localizationProvider.getLocalizedString(.snackBarDismiss)
    }
    var dismissAccessibilitylabel: String {
        localizationProvider.getLocalizedString(.snackBarDismissAccessibilityLabel)
    }
    var dismissAccessibilityHint: String {
        localizationProvider.getLocalizedString(.snackBarDismissAccessibilityHint)
    }

    func dismiss() {
        isDisplayed = false
    }

    func show() {
        isDisplayed = true
    }

    func update(diagnosticsState: DiagnosticsState) {
        // TODO: Implement UI Update on diagnostic change.
        print("[UFD] event here")
    }
}
