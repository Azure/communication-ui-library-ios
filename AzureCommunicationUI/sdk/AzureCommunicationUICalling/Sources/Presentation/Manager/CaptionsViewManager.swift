//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import Combine

class CaptionsViewManager: ObservableObject {
    private let callingSDKWrapper: CallingSDKWrapperProtocol
    @Published var captionData = [CallCompositeCaptionsData]()
    private var subscriptions = Set<AnyCancellable>()

    init(callingSDKWrapper: CallingSDKWrapperProtocol) {
        self.callingSDKWrapper = callingSDKWrapper
        subscribeToCaptions()
    }

    private func subscribeToCaptions() {
        callingSDKWrapper.callingEventsHandler.captionsReceived
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newData in
                self?.handleNewData(newData)
            }
            .store(in: &subscriptions)
    }

    private func handleNewData(_ newData: CallCompositeCaptionsData) {
        DispatchQueue.main.async {
            if let lastCaption = self.captionData.last,
               lastCaption.speakerRawId == newData.speakerRawId,
               lastCaption.resultType != .final {
                // If the last caption is not final and from the same speaker, update it
                self.captionData[self.captionData.count - 1] = newData
            } else {
                // Otherwise, append new data
                self.captionData.append(newData)
            }
        }
    }
    func clearCaptions() {
        captionData.removeAll()
    }
}
