//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct Reducer<State, Actions> {
    let reduce: (_ state: State, _ action: Actions) -> State
}