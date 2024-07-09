//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AVFoundation
import Combine

class MoreCallOptionsListViewModel: ObservableObject {
    private let localizationProvider: LocalizationProviderProtocol
    private let compositeViewModelFactory: CompositeViewModelFactoryProtocol
    let items: [DrawerListItemViewModel]

    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void,
         showSupportFormAction: @escaping () -> Void,
         isSupportFormAvailable: Bool,
         chatButtonClick:( () -> Void)? = nil,
         listButtonClick:( () -> Void)? = nil
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider

        let shareDebugInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .share,
            title: localizationProvider.getLocalizedString(.shareDiagnosticsInfo),
            accessibilityIdentifier: AccessibilityIdentifier.shareDiagnosticsAccessibilityID.rawValue,
            action: showSharingViewAction)

        var items = [shareDebugInfoModel]
        func chatButtonClickLocal(){
            chatButtonClick?()
        }
        func listButtonClickLocal(){
            listButtonClick?()
        }
let chatItem=compositeViewModelFactory.makeDrawerListItemViewModel(
    icon: .personFeedback,
    title: "Chat",
    accessibilityIdentifier: AccessibilityIdentifier.callingViewParticipantChatID.rawValue,
    action: chatButtonClickLocal)
        let waitingList=compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .personFeedback,
            title: "Waiting List",
            accessibilityIdentifier: AccessibilityIdentifier.callingViewParticipantChatID.rawValue,
            action: listButtonClickLocal)
        
//        if isSupportFormAvailable {
//            let reportErrorInfoModel = compositeViewModelFactory.makeDrawerListItemViewModel(
//                icon: .personFeedback,
//                title: localizationProvider.getLocalizedString(.supportFormReportIssueTitle),
//                accessibilityIdentifier: AccessibilityIdentifier.reportIssueAccessibilityID.rawValue,
//                action: showSupportFormAction)
//
//            items.append(reportErrorInfoModel)
//        }
        items.append(chatItem)
        items.append(waitingList)
        self.items = items
    }
}
