//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

struct DiagnosticsState: Equatable {

    var networkDiagnostic: NetworkDiagnosticModel?
    var networkQualitDiagnostic: NetworkQualityDiagnosticModel?
    var mediaDiagnostic: MediaDiagnosticModel?

    init(networkDiagnostic: NetworkDiagnosticModel? = nil,
         networkQualitDiagnostic: NetworkQualityDiagnosticModel? = nil,
         mediaDiagnostic: MediaDiagnosticModel? = nil) {
        self.networkDiagnostic = networkDiagnostic
        self.networkQualitDiagnostic = networkQualitDiagnostic
        self.mediaDiagnostic = mediaDiagnostic
    }
}
