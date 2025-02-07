//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import FluentUI
import UIKit
import SwiftUICore

class FontProvider {
    private let fluentTheme = FluentTheme()

    let display: Font
    let largeTitle: Font
    let title1: Font
    let title2: Font
    let title3: Font
    let body1Strong: Font
    let body1: Font
    let body2Strong: Font
    let body2: Font
    let caption1Strong: Font
    let caption1: Font
    let caption2: Font

    init(themeOptions: ThemeOptions?) {
        self.display = Font(fluentTheme.typography(.display))
        self.largeTitle = Font(fluentTheme.typography(.largeTitle))
        self.title1 = Font(fluentTheme.typography(.title1))
        self.title2 = Font(fluentTheme.typography(.title2))
        self.title3 = Font(fluentTheme.typography(.title3))
        self.body1Strong = Font(fluentTheme.typography(.body1Strong))
        self.body1 = Font(fluentTheme.typography(.body1))
        self.body2Strong = Font(fluentTheme.typography(.body2Strong))
        self.body2 = Font(fluentTheme.typography(.body2))
        self.caption1Strong = Font(fluentTheme.typography(.caption1Strong))
        self.caption1 = Font(fluentTheme.typography(.caption1))
        self.caption2 = Font(fluentTheme.typography(.caption2))
    }
}
