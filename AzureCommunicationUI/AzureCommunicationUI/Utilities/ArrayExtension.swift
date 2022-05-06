//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

extension Array {
    func chunkedAndReversed(into size: Int) -> [[Element]] {
        var chunkedArray = [[Element]]()
        guard self.count > 0 else {
            return chunkedArray
        }

        for index in 0...self.count {
            if index % size == 0, index != 0 {
                chunkedArray.append(Array(self[(index - size)..<index]))
            } else if index == self.count {
                let startingIdx = index - (index % size)
                if startingIdx < index - 1 {
                    chunkedArray.append(Array(self[startingIdx...]))
                } else {
                }
            }
        }

        return chunkedArray.reversed()
    }
}
