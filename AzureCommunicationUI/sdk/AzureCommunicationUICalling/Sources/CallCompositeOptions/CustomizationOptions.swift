//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

public struct CustomizationOptions {
    let customButtonViewData: [CustomButtonViewData]

    public init(customButtonViewData: [CustomButtonViewData]) {
        self.customButtonViewData = customButtonViewData
    }
}
