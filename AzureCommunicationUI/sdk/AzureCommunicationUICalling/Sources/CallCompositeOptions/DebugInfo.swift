//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// A Call Composite debug information.
public struct DebugInfo {
    /// The history of calls up to 30 days. Ordered ascending by call started date.
    public let callHistoryRecords: [CallHistoryRecord]
    public let callingUIVersion: String
    public let logFiles: [URL]
    // Take a screenshot
    func takeScreenshot() -> URL? {
        guard let screenshotImage = captureScreenshot()
        else { return nil }
        return saveScreenshot(screenshotImage)
    }
    /// Call history.
    init(callHistoryRecords: [CallHistoryRecord],
         callingUIVersion: String,
         logFiles: [URL]) {
        self.callHistoryRecords = callHistoryRecords
        self.callingUIVersion = callingUIVersion
        self.logFiles = logFiles
    }
}
