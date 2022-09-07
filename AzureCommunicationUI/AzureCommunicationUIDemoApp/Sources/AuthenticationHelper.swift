//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AzureCommunicationCalling

class AuthenticationHelper {
    static func getCommunicationToken(tokenUrl: URL) -> TokenRefresher {
        return { completionHandler in
            struct TokenResponse: Decodable {
                let token: String
            }
            var urlRequest = URLRequest(url: tokenUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
            urlRequest.httpMethod = "GET"
            URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
                if let error = error {
                    print(error)
                    completionHandler(nil, error)
                } else if let data = data {
                    do {
                        let res = try JSONDecoder().decode(TokenResponse.self, from: data)
                        print(res.token)
                        completionHandler(res.token, nil)
                    } catch let error {
                        print(error)
                        completionHandler(nil, error)
                    }
                }
            }.resume()
        }
    }

    static func fetchInitialToken(with tokenRefresher: TokenRefresher) async -> String? {
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
