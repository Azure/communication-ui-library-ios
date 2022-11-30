//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct IconButton: View {
    @ObservedObject var viewModel: IconButtonViewModel

    private let buttonDisabledColor = Color(StyleProvider.color.disableColor)
    private var iconImageSize: CGFloat {
        switch viewModel.buttonType {
        case .dismissButton:
            return 16
        default:
            return 24
        }
    }
    var width: CGFloat {
        switch viewModel.buttonType {
        case .controlButton,
             .roundedRectButton:
            return 60
        case .infoButton:
            return iconImageSize
        case .dismissButton:
            return 16
        case .cameraSwitchButtonFull,
             .cameraSwitchButtonPip:
            return 36
        }
    }
    var height: CGFloat {
        switch viewModel.buttonType {
        case .controlButton,
             .roundedRectButton:
            return 60
        case .infoButton:
            return iconImageSize
        case .dismissButton:
            return 16
        case .cameraSwitchButtonFull,
             .cameraSwitchButtonPip:
            return 36
        }
    }
    var buttonBackgroundColor: Color {
        switch viewModel.buttonType {
        case .roundedRectButton:
            return Color(StyleProvider.color.hangup)
        case .controlButton,
             .infoButton,
             .dismissButton:
            return .clear
        case .cameraSwitchButtonFull,
             .cameraSwitchButtonPip:
            return Color(StyleProvider.color.surfaceLightColor)
        }
    }
    var buttonForegroundColor: Color {
        switch viewModel.buttonType {
        case .controlButton:
            return Color(StyleProvider.color.onSurfaceColor)
        case .dismissButton:
            return Color(StyleProvider.color.onBackground)
        default:
            return .white
        }
    }

    var tappableWidth: CGFloat {
        switch viewModel.buttonType {
        case .cameraSwitchButtonPip,
             .cameraSwitchButtonFull,
             .infoButton:
            return 44
        default:
            return width
        }
    }

    var tappableHeight: CGFloat {
        switch viewModel.buttonType {
        case .cameraSwitchButtonPip,
             .cameraSwitchButtonFull,
             .infoButton:
            return 44
        default:
            return height
        }
    }

    var shapeCornerRadius: CGFloat {
        switch viewModel.buttonType {
        case .cameraSwitchButtonPip,
             .cameraSwitchButtonFull:
            return 4
        default:
            return 8
        }
    }

    var roundedCorners: UIRectCorner {
        switch viewModel.buttonType {
        case .cameraSwitchButtonPip:
            return [.bottomLeft]
        default:
            return [.allCorners]
        }
    }

    var body: some View {
        Group {
            Button(action: viewModel.action) {
                Icon(name: viewModel.iconName, size: iconImageSize)
                    .contentShape(Rectangle())
            }
            .disabled(viewModel.isDisabled)
            .foregroundColor(viewModel.isDisabled ? buttonDisabledColor : buttonForegroundColor)
            .frame(width: width, height: height, alignment: .center)
            .background(buttonBackgroundColor)
            .clipShape(RoundedCornersShape(radius: shapeCornerRadius, corners: roundedCorners))
            .accessibilityLabel(Text(viewModel.accessibilityLabel ?? ""))
            .accessibilityValue(Text(viewModel.accessibilityValue ?? ""))
            .accessibilityHint(Text(viewModel.accessibilityHint ?? ""))
        }
        .frame(width: tappableWidth,
               height: tappableHeight,
               alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            // ignore action in case if button is disabled
            // .disabled(_) is not used because tap is passed to superview when it shouldn't
            guard !viewModel.isDisabled else {
                return
            }
            viewModel.action()
        }
    }
}

struct RoundedCornersShape: Shape {
    let radius: CGFloat
    let corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
