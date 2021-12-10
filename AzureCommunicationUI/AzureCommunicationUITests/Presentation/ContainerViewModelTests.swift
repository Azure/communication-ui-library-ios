//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
@testable import AzureCommunicationUI

// class ContainerViewModelTests: XCTestCase {
//    
//    var reducer: ReducerMock!
//    var middleware: MiddlewareMock!
//    var store: StoreMock<AppState>!
//    var callingSDKWrapper: CallingGatewayMock!
//    var videoViewManager: VideoViewManagerMock!
//    var containerViewModel: ContainerViewModel!
//
//    override func setUp() {
//        reducer = mock(Reducer.self)
//        middleware = mock(Middleware.self)
//        given(middleware.apply(dispatch: any(), getState: any())).willReturn(
//            { next in
//                return { action in
//                        return next(action)
//                }
//            })
//        store = mock(Store<AppState>.self).initialize(reducer: reducer, middlewares: [middleware], state: AppState())
//        callingSDKWrapper = mock(CallingGateway.self)
//        videoViewManager = mock(VideoViewManager.self).initialize(callingSDKWrapper: callingSDKWrapper)
//        containerViewModel = ContainerViewModel(store: store, videoViewManager: videoViewManager)
//    }
// }
