//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import CallKit
import Foundation
import PushKit


class IncomingCallHandler: NSObject {

    private var callProvider: CXProvider

    override init() {
        let callConfig = CXProviderConfiguration()
        callConfig.supportsVideo = true
        callConfig.supportedHandleTypes = [.generic]

        let callProvider = CXProvider(configuration: callConfig)
        callProvider.setDelegate(self, queue: .main)
        super.init()

    }


    // Call this once at application startup
    func voIpRegistration() {
        // Create a push registry object
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: .main)
        // Set the registry's delegate to self
        voipRegistry.delegate = self
        // Set the push type to VoIP
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
}

extension IncomingCallHandler: PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {

        let token = pushCredentials.token
        // TODO: Register VoIP push token (a property of PKPushCredentials) with server
    }

    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        // TODO: Process the push, start up the app straight to the call screen?

        guard type == .voIP else {
            return
        }

        // Extract the call information from the push notification payload
        if let handle = payload.dictionaryPayload["handle"] as? String,
           let uuidString = payload.dictionaryPayload["callUUID"] as? String,
           let callUUID = UUID(uuidString: uuidString) {

            // Configure the call information data structures.
            let callUpdate = CXCallUpdate()
            let phoneNumber = CXHandle(type: .generic, value: handle)
            callUpdate.remoteHandle = phoneNumber


            // Report the call to CallKit, and let it display the call UI.
            callProvider?.reportNewIncomingCall(with: callUUID,
                        update: callUpdate, completion: { (error) in
               if error == nil {
                  // If the system allows the call to proceed, make a data record for it.
                  let newCall = VoipCall(callUUID, phoneNumber: phoneNumber)
                  self.callManager.addCall(newCall)
               }

               // Tell PushKit that the notification is handled.
               completion()
            })
        }


    }
}

extension IncomingCallHandler: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        <#code#>
    }
}
