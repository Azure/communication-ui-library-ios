//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct SourceViewSpace: View {
    let sourceView: UIView

    var body: some View {
        GeometryReader { geometry -> Color in
            sourceView.translatesAutoresizingMaskIntoConstraints = false
            sourceView.frame = geometry.frame(in: CoordinateSpace.global)
            sourceView.bounds = geometry.frame(in: CoordinateSpace.local)
            return .clear
        }
    }
}
