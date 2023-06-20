//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

struct ParticipantVideoFrameModel: Hashable, Equatable {

    let videoStreamIdentifier: String
    let buffer: CVPixelBuffer
}
