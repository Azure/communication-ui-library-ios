//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit

extension String {
    func isValidUrl() -> Bool {
        guard let url = URL(string: self) else {
            return false
        }

        return UIApplication.shared.canOpenURL(url)
    }
}
