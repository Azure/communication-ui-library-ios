//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

internal func captureScreenshot() -> UIImage? {
    guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    else { return nil }
    UIGraphicsBeginImageContext(window.frame.size)
    window.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

internal func saveScreenshot(_ image: UIImage) -> URL? {
    guard let imageData = image.pngData()
    else { return nil }
    // Format the current date and time for the filename
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyyMMdd_HHmmss"
    let timestamp = formatter.string(from: Date())
    // Define the file where the screenshot will be saved
    let screenshotFilename = "acs_calling_ui_\(timestamp).png"
    let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(screenshotFilename)
    do {
        try imageData.write(to: tempFileURL)
        return tempFileURL
    } catch {
        print("Error saving screenshot: \(error)")
        return nil
    }
}
