//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import Combine
import AzureCommunicationUICalling
import Alamofire

func sendSupportEventToServer(server: String, event: CallCompositeUserReportedIssue) {
    let url = "\(server)/receiveEvent" // Replace with your server URL
    // Prepare the data to be sent
    let parameters: [String: String] = [
        "userMessage": event.userMessage,
        "uiVersion": event.debugInfo.versions.callingUIVersion
    ]
    let headers: HTTPHeaders = [
        .contentType("multipart/form-data")
    ]
    AF.upload(multipartFormData: { multipartFormData in
        // Append text parameters
        for (key, value) in parameters {
            if let data = value.data(using: .utf8) {
                multipartFormData.append(data, withName: key)
            }
        }
        // Append files
        event.debugInfo.logFiles.forEach { fileURL in
            do {
                let fileData = try Data(contentsOf: fileURL)
                multipartFormData.append(fileData,
                                         withName: "logFiles[]",
                                         fileName: fileURL.lastPathComponent,
                                         mimeType: "application/octet-stream")
            } catch {
                print("Error reading file data: \(error)")
            }
        }
    }, to: url, method: .post, headers: headers).response { response in
        switch response.result {
        case .success(let responseData):
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                print("Success with response: \(responseString)")
            } else {
                print("Success, but couldn't decode response")
            }
        case .failure(let error):
            print("Failure: \(error.localizedDescription)")
        }
    }
}
