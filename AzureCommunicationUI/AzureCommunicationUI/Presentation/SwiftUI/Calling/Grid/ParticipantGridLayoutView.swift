//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

struct ParticipantGridLayoutView: View {
    var cellViewModels: [ParticipantGridCellViewModel]
    let rendererViewManager: RendererViewManager?
    let screenSize: ScreenSizeClassType
    let gridsMargin: CGFloat = 3

    var body: some View {
        Group {
            switch screenSize {
            case .iphonePortraitScreenSize:
                vGridLayout
            default:
                hGridLayout
            }
        }
    }

    func  getChunkedCellViewModelArray() -> [[ParticipantGridCellViewModel]] {
        let screenBasedRowSize = screenSize == .ipadScreenSize ? 3 : 2
        let rowSize = cellViewModels.count == 2 ? 1 : screenBasedRowSize
        return cellViewModels.chunkedAndReversed(into: rowSize)
    }

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
                                    rendererViewManager: rendererViewManager)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(StyleProvider.color.surface))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .accessibilityElement(children: .contain)

        }
    }

}
