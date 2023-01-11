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

    var unescapeHtmlString: String? {
        guard let htmlData = self.data(using: .utf16) else {
            return nil
        }
        let attributedOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf16.rawValue
        ]
        guard let attributedStr = try? NSAttributedString(
            data: htmlData,
            options: attributedOptions,
            documentAttributes: nil) else {
            return nil
        }
        return attributedStr.string.hasSuffix("\n") ?
        String(attributedStr.string.dropLast("\n".count)) : attributedStr.string
    }

    var isEmptyOrWhiteSpace: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
