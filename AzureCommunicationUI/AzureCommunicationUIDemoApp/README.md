# UI Mobile Library Demo App 

The sample app is a native iOS application developed using both SwiftUI and UIKit frameworks. It uses the Azure Communication UI library to empower the user experience.

## Getting Started

### Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
- A Mac running [Xcode](https://go.microsoft.com/fwLink/p/?LinkID=266532), along with a valid developer certificate installed into your Keychain. [CocoaPods](https://cocoapods.org/) must also be installed to fetch dependencies.
- A deployed Communication Services resource. Create a [Communication Services resource](https://docs.microsoft.com/azure/communication-services/quickstarts/create-communication-resource).
- Azure Communication Services Token. [See example](https://docs.microsoft.com/en-us/azure/communication-services/quickstarts/identity/quick-create-identity)
- (Optional) Create Azure Communication Services Token service URL. [See example](https://docs.microsoft.com/azure/communication-services/tutorials/trusted-service-tutorial).


### Before running the sample for the first time

1. After cloning the [Repo](https://github.com/Azure/azure-communication-ui-library-ios) in your local environment, `cd` to the `AzureCommunicationUI` folder in the root of the project directory.
2. Run `pod install`, this generates a `.xcworkspace` file.
3. (Optional) cd to the <project_folder>/AzureCommunicationUI/AzureCommunicationUIDemoApp/Sources folder.
4. (Optional) Run `touch EnvConfig.xcconfig` via the Command Line. 
5. (Optional) Add constants from following list to `EnvConfig.xcconfig` as the sample app's local configurations. 
   - Shared:
      - `acsToken`: a generated Azure Communication Services token
      - `acsTokenUrl`: the URL to request Azure Communication Services token (You must use https:/$()/ in the format of URL)
      - `displayName`: your preferred display name
   - for Calling:
      - `expiredAcsToken`: an expired Azure Communication Services token for UI testing
      - `groupCallId`: this a type of UUID used to start and join a meeting for Calling
      - `teamsMeetingLink`: the URL to a Teams meeting (You must use https:/$()/ in the format of URL) for Calling
      - `aadToken`: the AAD token for Calling
   - for Chat:
      - `userId`: the ID of the local user for Chat
      - `threadId`: the ID of chat thread for Chat
      - `endpointUrl`: the URL of where the chat endpoint should be

    ![EnvConfig](/docs/images/EnvConfig.png)

    Note: The `EnvConfig.xcconfig` file is created strictly for developers convenience. Those configurations can be input once the `AzureCommunicationUIDemoApp` is running.

### Run Sample

1. Open `AzureCommunicationUI.xcworkspace` file generated in the above step.
2. Select `AzureCommunicationUIDemoApp` scheme and target at any iOS simulator.
3. Hit `Run` or `⌘+R` to start running.

    ![SelectSimulator](/docs/images/SelectSimulator.png)

## Call with Chat teams interop demo

The demo application in the repository contains a demo app that will allow ACS interop with teams chat, during a teams call. To run this, clone this repository and in the AzureCommunicationUI/AzureCommunicationUIDemoApp run `pod install`.

Configure the ACS settings by placing an `EnvConfig.xcconfig` file in the `Sources` directory within the AzureCommunicationUIDemoApp folder. The file should contain the key-value pairs, with substituted values for your confguration:

``` text
endpointUrl = https:/$()/<ACS_ENDPOINT_URL>
userId = <ACS_USER_ID>
acsToken = <ACS_USER_TOKEN>
teamsMeetingLink = https:/$()/<TEAMS_MEETING_LINK>

```

Open the AzureCommunicationUIDemoApp.xcworkspace in that directory and run the demo app target.
You can use the call with chat button to access the demo, making sure that the token is used (token URL not currently supported) and the teams meeting URL is correctly populated.

You'll need to connect the call first, which enables the ACS user to enter the teams meeting. Once in call, tap the screen to show the participants bar at the top of the screen, on which there is a tap-able icon for chat. Tap this to go to the chat screen.
