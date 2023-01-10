//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

enum LocalizationKey: String {
    /* TopBarView */
    case chatWith0Person = "AzureCommunicationUIChat.ChatView.TopBarView.WaitingForOthersToJoin"
    case chatWith1Person = "AzureCommunicationUIChat.ChatView.TopBarView.CallWith1Person"
    // %d is for number of people in call
    case chatWithNPerson = "AzureCommunicationUIChat.ChatView.TopBarView.CallWithNPeople"

    /* TypingParticipantsView */
    case oneParticipantIsTyping =
            "AzureCommunicationUIChat.ChatView.TypingParticipantsView.oneParticipantIsTyping"
    case twoParticipantsAreTyping =
            "AzureCommunicationUIChat.ChatView.TypingParticipantsView.twoParticipantsAreTyping"
    case threeParticipantsAreTyping =
            "AzureCommunicationUIChat.ChatView.TypingParticipantsView.threeParticipantsAreTyping"
    case multipleParticipantsAreTyping =
            "AzureCommunicationUIChat.ChatView.TypingParticipantsView.multipleParticipantsAreTyping"
}
