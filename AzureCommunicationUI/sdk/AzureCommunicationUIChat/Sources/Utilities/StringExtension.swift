//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension String {
    func convertEpochStringToTimestamp() -> Date? {
        guard let timestampDouble = Double(self) else {
            return nil
        }
        let timestamp = Date(timeIntervalSince1970: timestampDouble / 1000)
        return timestamp
    }
}
