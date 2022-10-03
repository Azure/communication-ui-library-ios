//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum ChatAction: Equatable {
    case initializeChat
    case topicRetrieved(topic: String)
}
