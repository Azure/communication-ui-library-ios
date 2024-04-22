//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import Foundation
import UIKit
import Combine
import AzureCommunicationUICalling

// NOTE: to Enable Server Support Form Submission
// 1. Deploy the Node.js Server (Located in the Support Form quickstart)
// 2. Add AlamoFire to the `Podfile` of the demo app.
//
//    # Include AlamoFire for use with the User Reported Issue handler
//    # pod 'Alamofire', '5.8
//
// 3. Configure <TICKET_SERVER_URL>
// 4. Change the following to `$if true`
#if false
import Alamofire

/// Sends a support event to a server with details from a `CallCompositeUserReportedIssue`.
/// - Parameters:
///   - server: The URL of the server where the event will be sent.
///   - event: The `CallCompositeUserReportedIssue` containing details about the issue reported by the user.
///   - callback: A closure that is called when the operation is complete.
///               It provides a `Bool` indicating success or failure, and a `String`
///               containing the server's response or an error message.
func sendSupportEventToServer(event: CallCompositeUserReportedIssue,
                              callback: @escaping (Bool, String) -> Void) {
    let server = "<TICKET_SERVER_URL>"
    // Construct the URL for the endpoint.
    let url = "\(server)/receiveEvent" // Ensure this is replaced with the actual server URL.

    // Extract debugging information from the event.
    let debugInfo = event.debugInfo

    // Prepare the data to be sent as key-value pairs.
    let parameters: [String: String] = [
        "user_message": event.userMessage, // User's message about the issue.
        "ui_version": debugInfo.versions.callingUIVersion, // Version of the calling UI.
        "call_history": debugInfo.callHistoryRecords
            .map { $0.callIds.joined(separator: ",") }
            .joined(separator: "\n") // Call history, formatted.
    ]

    // Define the headers for the HTTP request.
    let headers: HTTPHeaders = [
        .contentType("multipart/form-data")
    ]

    // Perform the multipart/form-data upload.
    AF.upload(multipartFormData: { multipartFormData in
        // Append each parameter as a part of the form data.
        for (key, value) in parameters {
            if let data = value.data(using: .utf8) {
                multipartFormData.append(data, withName: key)
            }
        }

        // Append log files.
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
        // Handle the response from the server.
        switch response.result {
        case .success(let responseData):
            // Attempt to decode the response.
            if let data = responseData, let responseString = String(data: data, encoding: .utf8) {
                callback(true, responseString) // Success case.
            } else {
                callback(false, "Failed to decode response.") // Failed to decode.
            }
        case .failure(let error):
            // Handle any errors that occurred during the request.
            print("Error sending support event: \(error)")
            callback(false, "Error sending support event: \(error.localizedDescription)")
        }
    }
}
#else

/// Stub Method for `CallCompositeUserReportedIssue`.
/// Instantly returns a failed submission to server.
func sendSupportEventToServer(event: CallCompositeUserReportedIssue,
                              callback: @escaping (Bool, String) -> Void) {
    callback(false, "")
}
#endif
