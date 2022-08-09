//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

final class TokenManager {
    func fetchInitialToken(with tokenRefresher: TokenRefresher) async -> String? {
        return await withCheckedContinuation { continuation in
            tokenRefresher { token, error in
                if let error = error {
                    print("ERROR: Failed to fetch initial token. \(error.localizedDescription)")
                }
                continuation.resume(returning: token)
            }
        }
    }
}
