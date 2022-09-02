//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

struct ChatState {

    let localUser: LocalUserInfoModel

    init(localUser: LocalUserInfoModel) {
        self.localUser = localUser
    }
}
