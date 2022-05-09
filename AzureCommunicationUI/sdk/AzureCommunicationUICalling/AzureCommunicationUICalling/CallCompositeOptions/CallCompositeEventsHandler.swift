//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import AzureCommunicationCalling

public typealias CompositeErrorHandler = (CommunicationUIErrorEvent) -> Void
public struct CallCompositeEvents {
    public var didFail: CompositeErrorHandler?
}
