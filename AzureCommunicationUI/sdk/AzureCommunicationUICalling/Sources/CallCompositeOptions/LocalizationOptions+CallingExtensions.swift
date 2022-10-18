//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureUICommunicationCommon
import Foundation

public extension LocalizationOptions {

    /// Get supported locales the AzureCommunicationUICalling has predefined translations.
    /// - Returns: Get supported Locales the AzureCommunicationUICalling
    ///  has predefined translations.
    static var values: [Locale] {
        return Bundle(for: CallComposite.self).localizations.sorted()
            .map { Locale(identifier: $0) }
    }
}
