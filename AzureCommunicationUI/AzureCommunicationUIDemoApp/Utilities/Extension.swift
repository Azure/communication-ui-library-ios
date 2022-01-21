//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
extension URL {
    var queryDictionary: [String: String] {
        guard let query = self.query else { return [:]}
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = String(pair.dropFirst(key.count+1)).removingPercentEncoding ?? ""
            queryStrings[key.lowercased()] = value
        }
        return queryStrings
    }
}
