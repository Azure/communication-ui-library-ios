//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import AzureCore
import Foundation

public struct OrientationOptions: Equatable, RequestStringConvertible {
    internal enum OrientationOptionsKV {
        case portrait
        case landscape
        case allButUpsideDown
        case landscapeRight
        case landscapeLeft
        var rawValue: String {
            switch self {
            case .portrait:
                return "portrait"
            case .landscape:
                return "landscape"
            case .landscapeRight:
                return "landscapeRight"
            case .landscapeLeft:
                return "landscapeLeft"
            case .allButUpsideDown:
                return "allButUpsideDown"
            }
        }
        init(rawValue: String) {
            switch rawValue.lowercased() {
            case "portrait":
                self = .portrait
            case "landscape":
                self = .landscape
            case "landscaperight":
                self = .landscapeRight
            case "landscapeleft":
                self = .landscapeLeft
            default:
                self = .allButUpsideDown
            }
        }
    }

    private let value: OrientationOptionsKV

    public var requestString: String {
        return value.rawValue
    }

    private init(rawValue: String) {
        self.value = OrientationOptionsKV(rawValue: rawValue)
    }

    public static func == (lhs: OrientationOptions, rhs: OrientationOptions) -> Bool {
        return lhs.requestString == rhs.requestString
    }

    public static let portrait: OrientationOptions = .init(rawValue: "portrait")
    public static let landscape: OrientationOptions = .init(rawValue: "landscape")
    public static let landscapeRight: OrientationOptions = .init(rawValue: "landscapeRight")
    public static let landscapeLeft: OrientationOptions = .init(rawValue: "landscapeLeft")
    public static let allButUpsideDown: OrientationOptions = .init(rawValue: "allButUpsideDown")
}
