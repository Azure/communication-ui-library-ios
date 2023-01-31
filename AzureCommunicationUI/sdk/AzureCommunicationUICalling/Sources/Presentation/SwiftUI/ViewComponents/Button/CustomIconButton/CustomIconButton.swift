//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct CustomIconButton: View {
    @ObservedObject var viewModel: CustomButtonState

    private let buttonDisabledColor = Color(StyleProvider.color.disableColor)
    private var imageSize: CGFloat {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return 24
        }
    }
    var width: CGFloat {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return 35
        }
    }
    var height: CGFloat {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return 30
        }
    }
    var buttonBackgroundColor: Color {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return .clear
        }
    }
    var buttonForegroundColor: Color {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return .clear
        }
    }

    var tappableWidth: CGFloat {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return 44
        }
    }

    var tappableHeight: CGFloat {
        switch viewModel.type {
        case .callingViewInfoHeader:
            return 44
        }
    }

    var body: some View {
        Group {
            Button(action: {
                viewModel.action()
            }, label: {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .frame(width: imageSize, height: imageSize, alignment: .center)
                    .contentShape(Rectangle())
            })
            .overlay(badgeView)
            .disabled(viewModel.isDisabled)
            .foregroundColor(viewModel.isDisabled ? buttonDisabledColor : buttonForegroundColor)
            .frame(width: width, height: height, alignment: .center)
            .background(buttonBackgroundColor)
            .accessibilityLabel(Text(viewModel.description ?? ""))
            .accessibilityValue(Text(viewModel.description ?? ""))
            .accessibilityHint(Text(viewModel.description ?? ""))
        }
        .frame(width: tappableWidth,
               height: tappableHeight,
               alignment: .center)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.action()
        }
        .disabled(viewModel.isDisabled)
    }

    var badgeView: some View {
        Group {
            if let badgeCount = viewModel.badgeNumber, badgeCount > 0 {
                let badgeString = badgeCount > 99 ? String("99+") : String(badgeCount)
                Badge(text: badgeString)
            } else {
                EmptyView()
            }
        }
    }
}

struct Badge: View {
    private enum Constants {
        static let minSize: CGFloat = 12
    }

    let text: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            Text(text)
                .frame(minWidth: Constants.minSize,
                       minHeight: Constants.minSize)
                .foregroundColor(.white)
                .font(.system(size: 8))
                .padding(3)
                .background(Color(StyleProvider.color.primaryColor))
                .clipShape(Capsule())
                .alignmentGuide(.top) { $0[.bottom] }
                .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
        }
    }
}
