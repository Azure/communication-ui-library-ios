//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

class MappedSequence<S: Hashable, T>: Sequence {
    private class Node<S, T> {
        var key: S
        var value: T
        weak var prev: Node?
        weak var next: Node?

        init(key: S, value: T) {
            self.key = key
            self.value = value
        }
    }

    init() { }

    var count: Int {
        return keyNodeMap.count
    }

    private var keyNodeMap: [S: Node<S, T>] = [:]
    private var first: Node<S, T>?
    private var last: Node<S, T>?

    func makeIterator() -> AnyIterator<T> {
        var current: Node? = first
        return AnyIterator<T> { () -> T? in
            let value = current?.value
            current = current?.next
            return value
        }
    }

    func makeKeyIterator() -> AnyIterator<S> {
        var current: Node? = first
        return AnyIterator<S> { () -> S? in
            let value = current?.key
            current = current?.next
            return value
        }
    }

    func prepend(forKey: S, value: T) {
        if keyNodeMap[forKey] != nil {
            return
        }

        let node = Node<S, T>(key: forKey, value: value)
        keyNodeMap[forKey] = node

        if first == nil {
            first = node
            last = node
        } else {
            first?.prev = node
            node.next = first
            first = node
        }
    }

    func append(forKey: S, value: T) {
        if keyNodeMap[forKey] != nil {
            return
        }

        let node = Node<S, T>(key: forKey, value: value)
        keyNodeMap[forKey] = node

        if first == nil {
            first = node
            last = node
        } else {
            last?.next = node
            node.prev = last
            last = node
        }
    }

    func toArray() -> [T] {
        var array = [T]()
        self.forEach {array.append($0)}
        return array
    }

    @discardableResult
    func removeValue(forKey: S) -> T? {
        var value: T?

        if let nodeToRemove = keyNodeMap[forKey] {

            if keyNodeMap.count == 1 {
                first = nil
                last = nil
            } else if nodeToRemove === first {
                first = nodeToRemove.next
                first?.prev = nil
            } else if nodeToRemove === last {
                last = nodeToRemove.prev
                last?.next = nil
            } else {
                nodeToRemove.prev?.next = nodeToRemove.next
                nodeToRemove.next?.prev = nodeToRemove.prev
            }

            value = nodeToRemove.value

            nodeToRemove.prev = nil
            nodeToRemove.next = nil
            keyNodeMap.removeValue(forKey: forKey)
        }

        return value
    }

    @discardableResult
    func removeLast() -> T? {
        var value: T?

        if let lastKey = last?.key {
            value = self.removeValue(forKey: lastKey)
        }

        return value
    }

    func value(forKey: S) -> T? {
        if let node = keyNodeMap[forKey] {
            return node.value
        }

        return nil
    }
}
