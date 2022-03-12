//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

protocol Reducer {
    func reduce(_ state: ReduxState, _ action: Action) -> ReduxState
}
