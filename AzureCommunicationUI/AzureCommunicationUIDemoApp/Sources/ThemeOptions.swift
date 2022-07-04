//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureCommunicationUICalling

struct CustomColorTheming: ThemeOptions {
    private var envConfigSubject: EnvConfigSubject

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
    }

    var primaryColor: UIColor {
        return UIColor(envConfigSubject.primaryColor)
    }

    var primaryColorTint10: UIColor {
        return UIColor(envConfigSubject.tint10)
    }

    var primaryColorTint20: UIColor {
        return UIColor(envConfigSubject.tint20)
    }

    var primaryColorTint30: UIColor {
        return UIColor(envConfigSubject.tint30)
    }

    var colorSchemeOverride: UIUserInterfaceStyle {
        return envConfigSubject.colorSchemeOverride
    }
}

struct Theming: ThemeOptions {
    private var envConfigSubject: EnvConfigSubject

    init(envConfigSubject: EnvConfigSubject) {
        self.envConfigSubject = envConfigSubject
    }

    var colorSchemeOverride: UIUserInterfaceStyle {
        return envConfigSubject.colorSchemeOverride
    }
}
