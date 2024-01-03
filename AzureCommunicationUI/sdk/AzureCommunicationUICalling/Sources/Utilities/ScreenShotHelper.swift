//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

func captureScreenshot() -> UIImage? {
    guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    else { return nil }
    UIGraphicsBeginImageContext(window.frame.size)
    window.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func saveScreenshot(_ image: UIImage) -> URL? {
    guard let imageData = image.pngData()
    else { return nil }
    let tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("screenshot.png")
    do {
        try imageData.write(to: tempFileURL)
        return tempFileURL
    } catch {
        print("Error saving screenshot: \(error)")
        return nil
    }
}
