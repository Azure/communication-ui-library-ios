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
    var items: [DrawerListItemViewModel]

var eventButtonClick:((_ event:String) -> Void)? = nil
    @Published var recordingTitle: String="Start Recording"
  

    @objc private func updateRecording(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let value = userInfo["value"] as? Bool {
           
           
            self.recordingTitle=value ? "Stop Recording" : "Start Recording"
            if let index = items.firstIndex(where: { $0.accessibilityIdentifier == AccessibilityIdentifier.callingViewRecordID.rawValue }) {
                items.remove(at: index)
                let record=compositeViewModelFactory.makeDrawerListItemViewModel(
                    icon: .personFeedback,
                    title: self.recordingTitle ,
                    accessibilityIdentifier: AccessibilityIdentifier.callingViewRecordID.rawValue,
                    action: recordButtonClickLocal)
                items.insert(record, at: index)
                }
            
         
        }
    }
    func recordButtonClickLocal(){
        eventButtonClick?("recordButtonClick")
    }
    init(compositeViewModelFactory: CompositeViewModelFactoryProtocol,
         localizationProvider: LocalizationProviderProtocol,
         showSharingViewAction: @escaping () -> Void,
         showSupportFormAction: @escaping () -> Void,
         isSupportFormAvailable: Bool,
         eventButtonClick:((_ event:String) -> Void)? = nil,
         listButtonClick:( () -> Void)? = nil
    ) {
        self.compositeViewModelFactory = compositeViewModelFactory
        self.localizationProvider = localizationProvider

        self.recordingTitle="Start Recording"
        self.eventButtonClick=eventButtonClick;
        func chatButtonClickLocal(){
            eventButtonClick?("ChatButtonClick")
        }
       
        func screenShareButtonClickLocal(){
            eventButtonClick?("screenShareButtonClick")
        }
        func listButtonClickLocal(){
            eventButtonClick?("listButtonClick")
        }
        func recordButtonClickLocal(){
            eventButtonClick?("recordButtonClick")
        }
let chatItem=compositeViewModelFactory.makeDrawerListItemViewModel(
    icon: .personFeedback,
    title: "Chat",
    accessibilityIdentifier: AccessibilityIdentifier.callingViewParticipantChatID.rawValue,
    action: chatButtonClickLocal)
        
        var items = [chatItem]
     
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
        let record=compositeViewModelFactory.makeDrawerListItemViewModel(
            icon: .personFeedback,
            title: "Start Recording" ,
            accessibilityIdentifier: AccessibilityIdentifier.callingViewRecordID.rawValue,
            action: recordButtonClickLocal)
        items.append(record)
        items.append(waitingList)
       

        self.items = items
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateRecording(_: )), name: NSNotification.Name(rawValue: "updateRecording"), object: nil)
    }
    
    deinit {
           // Remove observer when ViewModel is deallocated
           NotificationCenter.default.removeObserver(self)
       }
}
