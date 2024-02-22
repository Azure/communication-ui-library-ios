//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import Combine
import AzureCommunicationUICalling
import Alamofire

func sendSupportEventToServer(server: String,
                              event: CallCompositeUserReportedIssue,
                              callback: @escaping (Bool, String) -> Void) {
    let url = "\(server)/receiveEvent" // Replace with your server URL
    let debugInfo = event.debugInfo

    // Prepare the data to be sent
    let parameters: [String: String] = [
        "user_message": event.userMessage,
        "ui_version": debugInfo.versions.callingUIVersion,
        "call_history": debugInfo.callHistoryRecords
            .map { p in "" + p.callIds.joined(separator: ",")}
            .joined(separator: "\n")
    ]
    let headers: HTTPHeaders = [
        .contentType("multipart/form-data")
    ]
    AF.upload(multipartFormData: { multipartFormData in
        for (key, value) in parameters {
            if let data = value.data(using: .utf8) {
                multipartFormData.append(data, withName: key)
            }
        }
        // Append files
        debugInfo.logFiles.forEach { fileURL in
            do {
                let fileData = try Data(contentsOf: fileURL)
                multipartFormData.append(fileData,
                                         withName: "log_files",
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
                callback(true, responseString)
            } else {
                callback(false, "")
            }
        case .failure(let error):
            print("Error sending support event: \(error)")
            callback(false, "Error sending support event: \(error.localizedDescription)")
        }
    }
}
