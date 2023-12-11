//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

class SupportFormViewModel: ObservableObject {
    // Published properties that the view can observe
    @Published var messageText: String = "Please describe your issue..."
    @Published var includeScreenshot: Bool = true
    // Any additional properties your ViewModel needs

    init() {
        // Initialize your ViewModel here if needed
    }

    // Function to handle the send action
    func sendReport() {
        print("SEND TEST" + messageText)
        // Implement the logic to send the report
        // This might include validating the input, preparing the data,
        // and actually sending it to a server or handling it as needed
    }

    // Any additional methods your ViewModel needs
}
