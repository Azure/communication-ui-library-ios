//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine
@testable import AzureCommunicationUICalling

class PermissionsManagerMocking: PermissionsManager {
    private var requestWasCalled: Bool = false
    private var requestWasCalledWithPermission: AppPermission?

    var didResolveStatus: Bool = false
    var didRequestPermission: Bool = false

    func resolveStatus(for permission: AppPermission) -> AppPermission.Status {
        return .granted
    }

    func request(_ permission: AppPermission) -> Future<AppPermission.Status, Never> {
        requestWasCalled = true
        requestWasCalledWithPermission = permission
        return Future { promise in
            promise(Result.success(.granted))
        }
    }

    func requestWasCalledWith(permission: AppPermission) -> Bool {
        return requestWasCalled && permission == requestWasCalledWithPermission
    }
}
