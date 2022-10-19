//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

@_spi(common) public struct Reducer<State, Actions> {
    public init(_ reduce: @escaping (_ state: State, _ action: Actions) -> State) {
        self.reduce = reduce
    }
    
    public let reduce: (_ state: State, _ action: Actions) -> State
}
