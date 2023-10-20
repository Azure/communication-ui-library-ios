//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

enum DiagnosticsAction: Equatable {
    case networkQuality(diagnostic: NetworkQualityDiagnosticModel)
    case network(diagnostic: NetworkDiagnosticModel)
    case media(diagnostic: MediaDiagnosticModel)
    case dismissNetworkQuality(diagnostic: NetworkQualityCallDiagnostic)
    case dismissNetwork(diagnostic: NetworkCallDiagnostic)
    case dismissMedia(diagnostic: MediaCallDiagnostic)
}
