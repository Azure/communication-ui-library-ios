//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

@_spi(common) import AzureCommunicationUICommon
import Foundation
import SwiftUI

protocol LocalizationProviderProtocol {
    var isRightToLeft: Bool { get }
}

class LocalizationProvider: LocalizationProviderProtocol {
    private let logger: Logger
    private(set) var isRightToLeft: Bool = false

    init(logger: Logger) {
        self.logger = logger
    }
}
