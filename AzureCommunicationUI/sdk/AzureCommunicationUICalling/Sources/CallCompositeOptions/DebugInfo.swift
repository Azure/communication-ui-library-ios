//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Encapsulates debug information for an ACS Call Composite, including call history, SDK version, and log files.
public struct DebugInfo {
    /// The history of calls, stored as an array of `CallHistoryRecord` objects, covering up to the last 30 days.
    /// These records are sorted in ascending order based on the date each call was started.
    public let callHistoryRecords: [CallHistoryRecord]

    /// A string representing the version of the ACS Calling UI SDK currently in use.
    public let callingUIVersion: String

    /// An array of `URL` objects, each pointing to a current log file of the ACS Calling Composite.
    /// These files are intended for use in debugging and providing support.
    public let logFiles: [URL]

    /// Attempts to capture a screenshot of the current call composite interface.
    ///
    /// - Returns: A `URL` pointing to the saved screenshot image in the temporary/cache directory,
    ///            or `nil` if it was not possible to take a screenshot.
    func takeScreenshot() -> URL? {
        guard let screenshotImage = captureScreenshot() else {
            return nil
        }
        return saveScreenshot(screenshotImage)
    }

    /// Initializes a new `DebugInfo` with the specified call history records, calling UI SDK version, and log files.
    ///
    /// - Parameters:
    ///   - callHistoryRecords: An array of `CallHistoryRecord` objects representing the call history.
    ///   - callingUIVersion: The version of the ACS Calling UI SDK.
    ///   - logFiles: An array of `URL` objects pointing to log files.
    init(callHistoryRecords: [CallHistoryRecord], callingUIVersion: String, logFiles: [URL]) {
        self.callHistoryRecords = callHistoryRecords
        self.callingUIVersion = callingUIVersion
        self.logFiles = logFiles
    }
}
