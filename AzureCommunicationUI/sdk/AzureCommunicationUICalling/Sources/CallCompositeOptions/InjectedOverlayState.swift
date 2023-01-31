//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

class InjectedOverlayState: ObservableObject {
    @Published var injectedView: AnyView?
}
