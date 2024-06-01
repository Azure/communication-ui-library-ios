//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import FluentUI

internal struct LeaveCallConfirmationView: View {
    @ObservedObject var viewModel: LeaveCallConfirmationViewModel

    init(viewModel: LeaveCallConfirmationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            ForEach(viewModel.options) { option in
                Text(option.title)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .onTapGesture {
                        option.action()
                        print("\(option) tapped")
                    }
            }
        }
    }
}
