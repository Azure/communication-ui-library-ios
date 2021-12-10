// ----------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// ----------------------------------------------------------------

import Foundation

enum EnvConfig: String {
    case acsToken
    case acsTokenUrl
    case displayName
    case groupCallId
    case teamsMeetingLink

    func value() -> String {
        guard let infoDict = Bundle.main.infoDictionary,
              let value = infoDict[self.rawValue] as? String else {
            return ""
        }
        return value
    }

}
