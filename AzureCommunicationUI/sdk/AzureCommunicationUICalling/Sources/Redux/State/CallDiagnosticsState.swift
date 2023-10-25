//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

struct CallDiagnosticsState: Equatable {

    var networkDiagnostic: NetworkDiagnosticModel?
    var networkQualityDiagnostic: NetworkQualityDiagnosticModel?
    var mediaDiagnostic: MediaDiagnosticModel?

    init(networkDiagnostic: NetworkDiagnosticModel? = nil,
         networkQualityDiagnostic: NetworkQualityDiagnosticModel? = nil,
         mediaDiagnostic: MediaDiagnosticModel? = nil) {
        self.networkDiagnostic = networkDiagnostic
        self.networkQualityDiagnostic = networkQualityDiagnostic
        self.mediaDiagnostic = mediaDiagnostic
    }
}
