//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ParticipantGridLayoutView: View {
    var cellViewModels: [ParticipantGridCellViewModel]
    let rendererViewManager: RendererViewManager?
    let avatarViewManager: AvatarViewManagerProtocol
    let screenSize: ScreenSizeClassType
    let gridsMargin: CGFloat = 3
    @Orientation var orientation: UIDeviceOrientation

    var body: some View {
        Group {
            switch screenSize {
            case .iphonePortraitScreenSize:
                vGridLayout
            default:
                let cellCount = cellViewModels.count
                let isPortrait = orientation.isPortrait
                let isiPadLanscape = orientation.isLandscape && screenSize == .ipadScreenSize
                let isiPadPortrait = isPortrait
                    && (screenSize == .ipadScreenSize)
                if (cellCount == 5 && isiPadLanscape)
                    || (cellCount == 8 && isiPadPortrait)
                    || (cellCount == 7 && isiPadPortrait)
                    || (cellCount == 3 && isiPadLanscape) {
                    vGridLayout
                } else {
                    hGridLayout
                }
            }
        }
    }

    func getChunkedCellViewModelArray() -> [[ParticipantGridCellViewModel]] {
        let cellCount = cellViewModels.count
        let vGridLayout = screenSize == .iphonePortraitScreenSize
        let isPortrait = orientation.isPortrait
        let isiPadLanscape = orientation.isLandscape && (screenSize == .ipadScreenSize)
        let isiPadPortrait = isPortrait && screenSize == .ipadScreenSize

        var screenBasedRowSize = 2
        if screenSize != .ipadScreenSize {
            // iPhone layout is kept the same way as before
            screenBasedRowSize = cellViewModels.count == 2 ? 1 : 2
        } else if cellCount <= 2 {
            // iPad layout for having 1 and 2 remote participants
            screenBasedRowSize = cellCount == 2 && isiPadPortrait ? 2 : 1
        } else if cellCount % 2 == 0 {
            // iPad layout for having 4, 6 and 8 remote participants
            screenBasedRowSize = (isiPadLanscape && cellCount < 8) || (isPortrait && cellCount < 6) ? 2 : 3
        } else if cellCount % 3 == 0 {
            // iPad layout for having 3 and 9 remote participants
            screenBasedRowSize = cellCount < 9 ? 2 : 3
        } else {
            // iPad layout for having 5 and 7 remote participants
            screenBasedRowSize = cellCount < 5 ? 2 : 3
        }

        return cellViewModels.chunkedAndReversed(into: screenBasedRowSize,
                                                 vGridLayout: vGridLayout || isiPadLanscape)
    }

    /// Grid layout used in displying grid items on iPad and iPhone landscape mode
    var hGridLayout: some View {
        let chunkedArray = getChunkedCellViewModelArray()
        return HStack(spacing: gridsMargin) {
            ForEach(0..<chunkedArray.count, id: \.self) { index in
                VStack(spacing: gridsMargin) {
                    getRowView(cellsViewModel: chunkedArray[index])
                }
            }
        }
        .background(Color(StyleProvider.color.gridLayoutBackground))
        .accessibilityElement(children: .contain)
    }

    /// Grid layout used in displying grid items on iPhone portrait mode
    var vGridLayout: some View {
        let chunkedArray = getChunkedCellViewModelArray()
        return VStack(spacing: gridsMargin) {
            ForEach(0..<chunkedArray.count, id: \.self) { index in
                HStack(spacing: gridsMargin) {
                    getRowView(cellsViewModel: chunkedArray[index])
                }
            }
        }
        .background(Color(StyleProvider.color.gridLayoutBackground))
        .accessibilityElement(children: .contain)
    }

    func getRowView(cellsViewModel: [ParticipantGridCellViewModel]) -> some View {
        return ForEach(cellsViewModel) { vm in
            ParticipantGridCellView(viewModel: vm,
                                    rendererViewManager: rendererViewManager,
                                    avatarViewManager: avatarViewManager)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(StyleProvider.color.surface))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .accessibilityElement(children: .contain)

        }
    }
}
