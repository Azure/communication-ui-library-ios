//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit

public enum CustomButtonType {
    case callingViewInfoHeader
}

public class CustomButtonViewData {
    public var image: UIImage! {
        get {
            return state.image
        }
        set {
            state.image = newValue
        }
    }

    public var description: String! {
        get {
            return state.description
        }
        set {
            state.description = newValue
        }
    }

    public var badgeNumber: Int? {
        get {
            return state.badgeNumber
        }
        set {
            state.badgeNumber = newValue
        }
    }

    public var isDisabled: Bool {
        get {
            return state.isDisabled
        }
        set {
            state.isDisabled = newValue
        }
    }

    public var onClick: ((_ sender: CustomButtonViewData) -> Void)? = nil
    {
        didSet {
            state.action = { [weak self] in
//                guard let self = self else {
//                    return
//                }
                self?.onClick?(self?)
            }
        }
    }

    var state: CustomButtonState

    public init(type: CustomButtonType,
                image: UIImage,
                label: String,
                badgeNumber: Int? = nil,
                onClick: ((_ sender: CustomButtonViewData) -> Void)?) {
        self.state = CustomButtonState(type: type,
                                       image: image,
                                       label: label,
                                       badgeNumber: badgeNumber)
        self.state.action = { [weak self] in
//            guard let self = self else {
//                return
//            }
            onClick?(self?)
        }
    }
}
