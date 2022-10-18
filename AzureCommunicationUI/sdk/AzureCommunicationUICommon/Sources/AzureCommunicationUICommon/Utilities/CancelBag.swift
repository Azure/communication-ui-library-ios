//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine

@_spi(common) public final class CancelBag {
    fileprivate(set) var subscriptions = Set<AnyCancellable>()

    public init() {}

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

@_spi(common) public extension AnyCancellable {

    func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
