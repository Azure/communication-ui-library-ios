//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct DraggableLocalVideoView: View {
    let viewModel: CallingViewModel
    let avatarManager: AvatarViewManager
    let viewManager: VideoViewManager
    @Binding var pipPosition: CGPoint?
    @GestureState var pipDragStartPosition: CGPoint?
    @Environment(\.horizontalSizeClass) var widthSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var heightSizeClass: UserInterfaceSizeClass?

    var body: some View {
        GeometryReader { geometry in
            let size = getPipSize(parentSize: geometry.size)
            localVideoPipView
                .frame(width: size.width, height: size.height, alignment: .center)
                .position(self.pipPosition!)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let containerBounds = getContainerBounds(bounds: geometry.frame(in: .local))
                            let translatedPipPosition = getTranslatedPipPosition(
                                currentPipPosition: self.pipPosition!,
                                pipDragStartPosition: self.pipDragStartPosition,
                                translation: value.translation,
                                isRightToLeft: viewModel.isRightToLeft)
                            self.pipPosition = getBoundedPipPosition(
                                currentPipPosition: self.pipPosition!,
                                requestedPipPosition: translatedPipPosition,
                                bounds: containerBounds)
                        }
                        .updating($pipDragStartPosition) { (_, startLocation, _) in
                            startLocation = startLocation ?? self.pipPosition
                        }
                )
        }
    }

    var localVideoPipView: some View {
        let shapeCornerRadius: CGFloat = 4
        return Group {
            LocalVideoView(viewModel: viewModel.localVideoViewModel,
                           viewManager: viewManager,
                           viewType: .localVideoPip,
                           avatarManager: avatarManager)
            .background(Color(StyleProvider.color.backgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: shapeCornerRadius))
        }
    }

    private func getSizeClass() -> ScreenSizeClassType {
        switch (widthSizeClass, heightSizeClass) {
        case (.compact, .regular):
            return .iphonePortraitScreenSize
        case (.compact, .compact),
            (.regular, .compact):
            return .iphoneLandscapeScreenSize
        default:
            return .ipadScreenSize
        }
    }

    private func getContainerBounds(bounds: CGRect) -> CGRect {
        let pipSize = getPipSize(parentSize: bounds.size)
        let isiPad = getSizeClass() == .ipadScreenSize
        let padding = isiPad ? 8.0 : 12.0
        let containerBounds = bounds.inset(by: UIEdgeInsets(
            top: pipSize.height / 2.0 + padding,
            left: pipSize.width / 2.0 + padding,
            bottom: pipSize.height / 2.0 + padding,
            right: pipSize.width / 2.0 + padding))
        return containerBounds
    }

    private func getTranslatedPipPosition(
        currentPipPosition: CGPoint,
        pipDragStartPosition: CGPoint?,
        translation: CGSize,
        isRightToLeft: Bool) -> CGPoint {
            var translatedPipPosition = pipDragStartPosition ?? currentPipPosition
            translatedPipPosition.x += isRightToLeft
            ? -translation.width
            : translation.width
            translatedPipPosition.y += translation.height
            return translatedPipPosition
        }

    private func getBoundedPipPosition(
        currentPipPosition: CGPoint,
        requestedPipPosition: CGPoint,
        bounds: CGRect) -> CGPoint {
            var boundedPipPosition = currentPipPosition

            if bounds.contains(requestedPipPosition) {
                boundedPipPosition = requestedPipPosition
            } else if requestedPipPosition.x > bounds.minX && requestedPipPosition.x < bounds.maxX {
                boundedPipPosition.x = requestedPipPosition.x
                boundedPipPosition.y = getMinMaxLimitedValue(
                    value: requestedPipPosition.y,
                    min: bounds.minY,
                    max: bounds.maxY)
            } else if requestedPipPosition.y > bounds.minY && requestedPipPosition.y < bounds.maxY {
                boundedPipPosition.x = getMinMaxLimitedValue(
                    value: requestedPipPosition.x,
                    min: bounds.minX,
                    max: bounds.maxX)
                boundedPipPosition.y = requestedPipPosition.y
            }

            return boundedPipPosition
        }

    private func getPipSize(parentSize: CGSize? = nil) -> CGSize {
        let isPortraitMode = getSizeClass() != .iphoneLandscapeScreenSize
        let isiPad = getSizeClass() == .ipadScreenSize

        func defaultSize() -> CGSize {
            let width = isPortraitMode ? 72 : 104
            let height = isPortraitMode ? 104 : 72
            let size = CGSize(width: width, height: height)
            return size
        }

        if isiPad {
            if let parentSize = parentSize {
                if parentSize.width < parentSize.height {
                    // portrait
                    return CGSize(width: 80.0, height: 115.0)
                } else {
                    // landscape
                    return CGSize(width: 152.0, height: 115.0)
                }
            }
        }

        return defaultSize()
    }

    private func getMinMaxLimitedValue(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        var limitedValue = value
        if value < min {
            limitedValue = min
        } else if value > max {
            limitedValue = max
        }
        return limitedValue
    }
}
