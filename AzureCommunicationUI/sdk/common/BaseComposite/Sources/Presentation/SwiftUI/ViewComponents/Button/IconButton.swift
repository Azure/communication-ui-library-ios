//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

extension IconButtonViewModel.ButtonType {
    var iconImageSize: CGFloat {
        switch self {
        default:
            return 24
        }
    }

    var width: CGFloat {
        switch self {
        case .controlButton:
            return 60
        }
    }

    var height: CGFloat {
        switch self {
        case .controlButton:
            return 60
        }
    }

    var buttonBackgroundColor: Color {
        switch self {
        case .controlButton:
            return .clear
        }
    }

    var buttonForegroundColor: Color {
        switch self {
        case .controlButton:
            return Color(StyleProvider.color.textDominant)
        }
    }

    var tappableWidth: CGFloat {
        switch self {
        default:
            return width
        }
    }

    var tappableHeight: CGFloat {
        switch self {
        default:
            return height
        }
    }

    var shapeCornerRadius: CGFloat {
        switch self {
        default:
            return 8
        }
    }

    var roundedCorners: UIRectCorner {
        switch self {
        default:
            return [.allCorners]
        }
    }
}

struct IconButton: View {
    @ObservedObject var viewModel: IconButtonViewModel

    private let buttonDisabledColor = Color(StyleProvider.color.disableColor)

    var body: some View {
        let buttonType = viewModel.buttonType
        Group {
            Button(action: viewModel.action) {
                Icon(name: viewModel.iconName, size: buttonType.iconImageSize)
                    .contentShape(Rectangle())
            }
            .disabled(viewModel.isDisabled)
            .foregroundColor(viewModel.isDisabled ? buttonDisabledColor : buttonType.buttonForegroundColor)
            .frame(width: buttonType.width, height: buttonType.height, alignment: .center)
            .background(buttonType.buttonBackgroundColor)
            .clipShape(RoundedCornersShape(radius: buttonType.shapeCornerRadius, corners: buttonType.roundedCorners))
            .accessibilityLabel(Text(viewModel.accessibilityLabel ?? ""))
            .accessibilityValue(Text(viewModel.accessibilityValue ?? ""))
            .accessibilityHint(Text(viewModel.accessibilityHint ?? ""))
        }
        .frame(width: buttonType.tappableWidth,
               height: buttonType.tappableHeight,
               alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.action()
        }
        .disabled(viewModel.isDisabled)
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
