//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

@_spi(common) public final class CancelBag {

    public init() { }
    
    fileprivate(set) var subscriptions = Set<AnyCancellable>()

    public func cancel() {
        subscriptions.removeAll()
    }

    public func collect(@Builder _ cancellables: () -> [AnyCancellable]) {
        subscriptions.formUnion(cancellables())
    }

    @resultBuilder
    struct Builder {
        static func buildBlock(_ cancellables: AnyCancellable...) -> [AnyCancellable] {
            return cancellables
        }
    }
}

extension AnyCancellable {

    @_spi(common) public func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
