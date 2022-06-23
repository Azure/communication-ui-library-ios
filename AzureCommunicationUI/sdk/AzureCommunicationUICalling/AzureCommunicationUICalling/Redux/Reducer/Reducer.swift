//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import Foundation

struct Reducer<State, Action> {
    var reduce: (_ state: State, _ action: Action) -> State
}
