//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ConfirmLeaveOverlayView: View {
    @ObservedObject var viewModel: CallingViewModel
    let controlWidth: CGFloat = 340

    @Environment(\.screenSizeClass) var screenSizeClass: ScreenSizeClassType

    var body: some View {
        GeometryReader { geometry in
            VStack {
                leaveCallButton
                    .frame(width: getButtonWidth(from: geometry))
                    .padding(.all)
                    .accessibilitySortPriority(1)
                    .accessibilityIdentifier("AzureCommunicationUI.CallingView.PrimaryButton.LeaveCall")
                cancelButton
                    .frame(width: getButtonWidth(from: geometry))
                    .padding(.horizontal)
                    .accessibilitySortPriority(0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.7))
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                viewModel.dismissConfirmLeaveOverlay()
            }
        }
    }

    func getButtonWidth(from geometry: GeometryProxy) -> CGFloat {
        if screenSizeClass == .ipadScreenSize {
            return geometry.size.width * 0.4
        }
        return min(controlWidth, geometry.size.width * 0.8)
    }

    var leaveCallButton: some View {
        return PrimaryButton(viewModel: viewModel.getLeaveCallButtonViewModel())
    }

    var cancelButton: some View {
        return PrimaryButton(viewModel: viewModel.getCancelButtonViewModel())
    }
}
