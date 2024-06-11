//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import XCTest
import AzureCommunicationCommon
import CallKit
import AVFoundation
@testable import AzureCommunicationUICalling

class CallKitOptionsTests: XCTestCase {
    func incomingCallRemoteInfo(info: Caller) -> CallKitRemoteInfo {
        let cxHandle = CXHandle(type: .generic, value: "Incoming call")
        let callKitRemoteInfo = CallKitRemoteInfo(displayName: "test",
                                                               handle: cxHandle)
        return callKitRemoteInfo
    }

    func configureAudioSession() -> Error? {
        let audioSession = AVAudioSession.sharedInstance()
        let options: AVAudioSession.CategoryOptions = .allowBluetooth
        var configError: Error?
        do {
            try audioSession.setCategory(.playAndRecord, options: options)
        } catch {
            configError = error
        }
        return configError
    }

    func test_calkitoptions_default_init() {
        let callkitOptions = CallKitOptions()
        XCTAssertEqual(callkitOptions.providerConfig.maximumCallGroups, 1)
        XCTAssertEqual(callkitOptions.isCallHoldSupported, true)
        XCTAssertNil(callkitOptions.configureAudioSession)
        XCTAssertNil(callkitOptions.provideRemoteInfo)
    }

    func test_calkitoptions_init_with_options() {
        let providerConfig = CXProviderConfiguration()
        providerConfig.supportsVideo = true
        providerConfig.maximumCallGroups = 2
        providerConfig.maximumCallsPerCallGroup = 1
        providerConfig.includesCallsInRecents = true
        providerConfig.supportedHandleTypes = [.phoneNumber, .generic]
        let incomingCallRemoteInfo = incomingCallRemoteInfo
        let configureAudioSession = configureAudioSession
        let callkitOptions = CallKitOptions(providerConfig: providerConfig,
                                            isCallHoldSupported: false,
                                            provideRemoteInfo: incomingCallRemoteInfo,
                                            configureAudioSession: configureAudioSession)
        XCTAssertEqual(callkitOptions.providerConfig.maximumCallGroups, 2)
        XCTAssertEqual(callkitOptions.isCallHoldSupported, false)
        XCTAssertNotNil(callkitOptions.configureAudioSession)
        XCTAssertNotNil(callkitOptions.provideRemoteInfo)
    }

    func test_calkitinfo_test() {
        let cxHandle = CXHandle(type: .generic, value: "Incoming call")
        let callKitRemoteInfo = CallKitRemoteInfo(displayName: "test",
                                                               handle: cxHandle)
        XCTAssertEqual(callKitRemoteInfo.displayName, "test")
        XCTAssertEqual(callKitRemoteInfo.handle, cxHandle)
    }
}
