// ACSCallingShared
// This file was auto-generated from ACSCallingModelGA.cs.

#import <Foundation/Foundation.h>

#import <AzureCommunicationCommon/AzureCommunicationCommon-Swift.h>
#import "ACSVideoStreamRenderer.h"
#import "ACSVideoStreamRendererView.h"
#import "ACSStreamSize.h"
#import "ACSFeatures.h"

// Enumerations.
/// Additional failed states for Azure Communication Services
typedef NS_OPTIONS(NSInteger, ACSCallingCommunicationErrors)
{
    /// No errors
    ACSCallingCommunicationErrorsNone = 0,
    /// No Audio permissions available.
    ACSCallingCommunicationErrorsNoAudioPermission = 1,
    /// No Video permissions available.
    ACSCallingCommunicationErrorsNoVideoPermission = 2,
    /// No Video and Audio permissions available.
    ACSCallingCommunicationErrorsNoAudioAndVideoPermission = 3,
    /// Failed to process push notification payload.
    ACSCallingCommunicationErrorsReceivedInvalidPushNotificationPayload = 4,
    /// Receieved empty/invalid notification payload.
    ACSCallingCommunicationErrorsFailedToProcessPushNotificationPayload = 8,
    /// Receieved invalid group Id.
    ACSCallingCommunicationErrorsInvalidGuidGroupId = 16,
    /// Push notification device registration token is invalid.
    ACSCallingCommunicationErrorsInvalidPushNotificationDeviceRegistrationToken = 32,
    /// Cannot create multiple renderers for same device or stream.
    ACSCallingCommunicationErrorsMultipleRenderersNotSupported = 64,
    /// Renderer doesn't support creating multiple views.
    ACSCallingCommunicationErrorsMultipleViewsNotSupported = 128,
    /// The local video stream on the video options is invalid.
    ACSCallingCommunicationErrorsInvalidLocalVideoStreamForVideoOptions = 256,
    /// No multiple connections with same identity per app is allowed.
    ACSCallingCommunicationErrorsNoMultipleConnectionsWithSameIdentity = 512,
    /// Invalid server call Id because it's empty or has invalid values.
    ACSCallingCommunicationErrorsInvalidServerCallId = 1024,
    /// Failure while switch source on a local video stream.
    ACSCallingCommunicationErrorsLocalVideoStreamSwitchSourceFailure = 2048,
    /// Attempt to answer an incoming call that has been unplaced.
    ACSCallingCommunicationErrorsIncomingCallAlreadyUnplaced = 4096,
    /// Invalid meeting link provided.
    ACSCallingCommunicationErrorsInvalidMeetingLink = 16384,
    /// Attempt to add participant to a unconnected call.
    ACSCallingCommunicationErrorsParticipantAddedToUnconnectedCall = 32768,
    /// Participant already added to the call.
    ACSCallingCommunicationErrorsParticipantAlreadyAddedToCall = 65536,
    /// Call feature extension not found.
    ACSCallingCommunicationErrorsCallFeatureExtensionNotFound = 131072
} NS_SWIFT_NAME(CallingCommunicationErrors);

/// Direction of the camera
typedef NS_ENUM(NSInteger, ACSCameraFacing)
{
    /// Unknown
    ACSCameraFacingUnknown = 0,
    /// External device
    ACSCameraFacingExternal = 1,
    /// Front camera
    ACSCameraFacingFront = 2,
    /// Back camera
    ACSCameraFacingBack = 3,
    /// Panoramic camera
    ACSCameraFacingPanoramic = 4,
    /// Left front camera
    ACSCameraFacingLeftFront = 5,
    /// Right front camera
    ACSCameraFacingRightFront = 6
} NS_SWIFT_NAME(CameraFacing);

/// Describes the video device type
typedef NS_ENUM(NSInteger, ACSVideoDeviceType)
{
    /// Unknown type of video device
    ACSVideoDeviceTypeUnknown = 0,
    /// USB Camera Video Device
    ACSVideoDeviceTypeUsbCamera = 1,
    /// Capture Adapter Video Device
    ACSVideoDeviceTypeCaptureAdapter = 2,
    /// Virtual Video Device
    ACSVideoDeviceTypeVirtual = 3
} NS_SWIFT_NAME(VideoDeviceType);

/// Local and Remote Video Stream types
typedef NS_ENUM(NSInteger, ACSMediaStreamType)
{
    /// Video
    ACSMediaStreamTypeVideo = 1,
    /// Screen share
    ACSMediaStreamTypeScreenSharing = 2
} NS_SWIFT_NAME(MediaStreamType);

/// State of a participant in the call
typedef NS_ENUM(NSInteger, ACSParticipantState)
{
    /// Idle
    ACSParticipantStateIdle = 0,
    /// Early Media
    ACSParticipantStateEarlyMedia = 1,
    /// Connecting
    ACSParticipantStateConnecting = 2,
    /// Connected
    ACSParticipantStateConnected = 3,
    /// On Hold
    ACSParticipantStateHold = 4,
    /// In Lobby
    ACSParticipantStateInLobby = 5,
    /// Disconnected
    ACSParticipantStateDisconnected = 6,
    /// Ringing
    ACSParticipantStateRinging = 7
} NS_SWIFT_NAME(ParticipantState);

/// State of a call
typedef NS_ENUM(NSInteger, ACSCallState)
{
    /// None - disposed or applicable very early in lifetime of a call
    ACSCallStateNone = 0,
    /// Early Media
    ACSCallStateEarlyMedia = 1,
    /// Call is being connected
    ACSCallStateConnecting = 3,
    /// Call is ringing
    ACSCallStateRinging = 4,
    /// Call is connected
    ACSCallStateConnected = 5,
    /// Call held by local participant
    ACSCallStateLocalHold = 6,
    /// Call is being disconnected
    ACSCallStateDisconnecting = 7,
    /// Call is disconnected
    ACSCallStateDisconnected = 8,
    /// In Lobby
    ACSCallStateInLobby = 9,
    /// Call held by a remote participant
    ACSCallStateRemoteHold = 10
} NS_SWIFT_NAME(CallState);

/// Direction of a Call
typedef NS_ENUM(NSInteger, ACSCallDirection)
{
    /// Outgoing call
    ACSCallDirectionOutgoing = 1,
    /// Incoming call
    ACSCallDirectionIncoming = 2
} NS_SWIFT_NAME(CallDirection);

/// DTMF (Dual-Tone Multi-Frequency) tone for PSTN calls
typedef NS_ENUM(NSInteger, ACSDtmfTone)
{
    /// Zero
    ACSDtmfToneZero = 0,
    /// One
    ACSDtmfToneOne = 1,
    /// Two
    ACSDtmfToneTwo = 2,
    /// Three
    ACSDtmfToneThree = 3,
    /// Four
    ACSDtmfToneFour = 4,
    /// Five
    ACSDtmfToneFive = 5,
    /// Six
    ACSDtmfToneSix = 6,
    /// Seven
    ACSDtmfToneSeven = 7,
    /// Eight
    ACSDtmfToneEight = 8,
    /// Nine
    ACSDtmfToneNine = 9,
    /// Star
    ACSDtmfToneStar = 10,
    /// Pound
    ACSDtmfTonePound = 11,
    /// A
    ACSDtmfToneA = 12,
    /// B
    ACSDtmfToneB = 13,
    /// C
    ACSDtmfToneC = 14,
    /// D
    ACSDtmfToneD = 15,
    /// Flash
    ACSDtmfToneFlash = 16
} NS_SWIFT_NAME(DtmfTone);

/// Local and Remote Video scaling mode
typedef NS_ENUM(NSInteger, ACSScalingMode)
{
    /// Cropped
    ACSScalingModeCrop = 1,
    /// Fitted
    ACSScalingModeFit = 2
} NS_SWIFT_NAME(ScalingMode);

typedef NS_ENUM(NSInteger, ACSHandleType)
{
    ACSHandleTypeUnknown = 0,
    ACSHandleTypeGroupCallLocator = 1,
    ACSHandleTypeTeamsMeetingCoordinatesLocator = 2,
    ACSHandleTypeTeamsMeetingLinkLocator = 3,
    ACSHandleTypeRecordingCallFeature = 4,
    ACSHandleTypeTranscriptionCallFeature = 5
} NS_SWIFT_NAME(HandleType);

// MARK: Forward declarations.
@class ACSVideoOptions;
@class ACSLocalVideoStream;
@class ACSVideoDeviceInfo;
@class ACSAudioOptions;
@class ACSJoinCallOptions;
@class ACSAcceptCallOptions;
@class ACSStartCallOptions;
@class ACSAddPhoneNumberOptions;
@class ACSJoinMeetingLocator;
@class ACSGroupCallLocator;
@class ACSTeamsMeetingCoordinatesLocator;
@class ACSTeamsMeetingLinkLocator;
@class ACSCallerInfo;
@class ACSPushNotificationInfo;
@class ACSCallAgentOptions;
@class ACSEmergencyCallOptions;
@class ACSCallAgent;
@class ACSCall;
@class ACSRemoteParticipant;
@class ACSCallEndReason;
@class ACSRemoteVideoStream;
@class ACSPropertyChangedEventArgs;
@class ACSRemoteVideoStreamsEventArgs;
@class ACSParticipantsUpdatedEventArgs;
@class ACSLocalVideoStreamsUpdatedEventArgs;
@class ACSHangUpOptions;
@class ACSCallFeature;
@class ACSCallsUpdatedEventArgs;
@class ACSIncomingCall;
@class ACSCallClient;
@class ACSCallClientOptions;
@class ACSCallDiagnosticsOptions;
@class ACSDeviceManager;
@class ACSVideoDevicesUpdatedEventArgs;
@class ACSRecordingCallFeature;
@class ACSTranscriptionCallFeature;
@class ACSCreateViewOptions;
@protocol ACSCallAgentDelegate;
@class ACSCallAgentEvents;
@protocol ACSCallDelegate;
@class ACSCallEvents;
@protocol ACSRemoteParticipantDelegate;
@class ACSRemoteParticipantEvents;
@protocol ACSIncomingCallDelegate;
@class ACSIncomingCallEvents;
@protocol ACSDeviceManagerDelegate;
@class ACSDeviceManagerEvents;
@protocol ACSRecordingCallFeatureDelegate;
@class ACSRecordingCallFeatureEvents;
@protocol ACSTranscriptionCallFeatureDelegate;
@class ACSTranscriptionCallFeatureEvents;

NS_SWIFT_NAME(CallAgentEvents)
@interface ACSCallAgentEvents : NSObject
@property (copy, nullable) void (^onCallsUpdated)(ACSCallsUpdatedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIncomingCall)(ACSIncomingCall * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(CallEvents)
@interface ACSCallEvents : NSObject
@property (copy, nullable) void (^onIdChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onStateChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onRemoteParticipantsUpdated)(ACSParticipantsUpdatedEventArgs * _Nonnull);
@property (copy, nullable) void (^onLocalVideoStreamsUpdated)(ACSLocalVideoStreamsUpdatedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIsMutedChanged)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(RemoteParticipantEvents)
@interface ACSRemoteParticipantEvents : NSObject
@property (copy, nullable) void (^onStateChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIsMutedChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onIsSpeakingChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onDisplayNameChanged)(ACSPropertyChangedEventArgs * _Nonnull);
@property (copy, nullable) void (^onVideoStreamsUpdated)(ACSRemoteVideoStreamsEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(IncomingCallEvents)
@interface ACSIncomingCallEvents : NSObject
@property (copy, nullable) void (^onCallEnded)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(DeviceManagerEvents)
@interface ACSDeviceManagerEvents : NSObject
@property (copy, nullable) void (^onCamerasUpdated)(ACSVideoDevicesUpdatedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(RecordingCallFeatureEvents)
@interface ACSRecordingCallFeatureEvents : NSObject
@property (copy, nullable) void (^onIsRecordingActiveChanged)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

NS_SWIFT_NAME(TranscriptionCallFeatureEvents)
@interface ACSTranscriptionCallFeatureEvents : NSObject
@property (copy, nullable) void (^onIsTranscriptionActiveChanged)(ACSPropertyChangedEventArgs * _Nonnull);
- (void) removeAll;
@end

/**
 * A set of methods that are called by ACSCallAgent in response to important events.
 */
NS_SWIFT_NAME(CallAgentDelegate)
@protocol ACSCallAgentDelegate <NSObject>
@optional
- (void)onCallsUpdated:(ACSCallAgent * _Nonnull)callAgent :(ACSCallsUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( callAgent(_:didUpdateCalls:));
- (void)onIncomingCall:(ACSCallAgent * _Nonnull)callAgent :(ACSIncomingCall * _Nonnull)incomingCall NS_SWIFT_NAME( callAgent(_:didRecieveIncomingCall:));
@end

/**
 * A set of methods that are called by ACSCall in response to important events.
 */
NS_SWIFT_NAME(CallDelegate)
@protocol ACSCallDelegate <NSObject>
@optional
- (void)onIdChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeId:));
- (void)onStateChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeState:));
- (void)onRemoteParticipantsUpdated:(ACSCall * _Nonnull)call :(ACSParticipantsUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didUpdateRemoteParticipant:));
- (void)onLocalVideoStreamsUpdated:(ACSCall * _Nonnull)call :(ACSLocalVideoStreamsUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didUpdateLocalVideoStreams:));
- (void)onIsMutedChanged:(ACSCall * _Nonnull)call :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( call(_:didChangeMuteState:));
@end

/**
 * A set of methods that are called by ACSRemoteParticipant in response to important events.
 */
NS_SWIFT_NAME(RemoteParticipantDelegate)
@protocol ACSRemoteParticipantDelegate <NSObject>
@optional
- (void)onStateChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeState:));
- (void)onIsMutedChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeMuteState:));
- (void)onIsSpeakingChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeSpeakingState:));
- (void)onDisplayNameChanged:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didChangeDisplayName:));
- (void)onVideoStreamsUpdated:(ACSRemoteParticipant * _Nonnull)remoteParticipant :(ACSRemoteVideoStreamsEventArgs * _Nonnull)args NS_SWIFT_NAME( remoteParticipant(_:didUpdateVideoStreams:));
@end

/**
 * A set of methods that are called by ACSIncomingCall in response to important events.
 */
NS_SWIFT_NAME(IncomingCallDelegate)
@protocol ACSIncomingCallDelegate <NSObject>
@optional
- (void)onCallEnded:(ACSIncomingCall * _Nonnull)incomingCall :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( incomingCall(_:didEnd:));
@end

/**
 * A set of methods that are called by ACSDeviceManager in response to important events.
 */
NS_SWIFT_NAME(DeviceManagerDelegate)
@protocol ACSDeviceManagerDelegate <NSObject>
@optional
- (void)onCamerasUpdated:(ACSDeviceManager * _Nonnull)deviceManager :(ACSVideoDevicesUpdatedEventArgs * _Nonnull)args NS_SWIFT_NAME( deviceManager(_:didUpdateCameras:));
@end

/**
 * A set of methods that are called by ACSRecordingCallFeature in response to important events.
 */
NS_SWIFT_NAME(RecordingCallFeatureDelegate)
@protocol ACSRecordingCallFeatureDelegate <NSObject>
@optional
- (void)onIsRecordingActiveChanged:(ACSRecordingCallFeature * _Nonnull)recordingCallFeature :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( recordingCallFeature(_:didChangeRecordingState:));
@end

/**
 * A set of methods that are called by ACSTranscriptionCallFeature in response to important events.
 */
NS_SWIFT_NAME(TranscriptionCallFeatureDelegate)
@protocol ACSTranscriptionCallFeatureDelegate <NSObject>
@optional
- (void)onIsTranscriptionActiveChanged:(ACSTranscriptionCallFeature * _Nonnull)transcriptionCallFeature :(ACSPropertyChangedEventArgs * _Nonnull)args NS_SWIFT_NAME( transcriptionCallFeature(_:didChangeTranscriptionState:));
@end

/// Property bag class for Video Options. Use this class to set video options required during a call (start/accept/join)
NS_SWIFT_NAME(VideoOptions)
@interface ACSVideoOptions : NSObject
-(nonnull instancetype)init:(NSArray<ACSLocalVideoStream *> * _Nonnull )localVideoStreams NS_SWIFT_NAME( init(localVideoStreams:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The video stream that is used to render the video on the UI surface
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * localVideoStreams;

@end

/// Local video stream information
NS_SWIFT_NAME(LocalVideoStream)
@interface ACSLocalVideoStream : NSObject
-(nonnull instancetype)init:(ACSVideoDeviceInfo * _Nonnull )camera NS_SWIFT_NAME( init(camera:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video device to use as source for local video.
@property (retain, nonnull, readonly) ACSVideoDeviceInfo * source;

/// Sets to True when the local video stream is being sent on a call.
@property (readonly) BOOL isSending;

/// MediaStream type being used for the current local video stream (Video or ScreenShare).
@property (readonly) ACSMediaStreamType mediaStreamType;

// Class extension begins for LocalVideoStream.
-(void)switchSource:(ACSVideoDeviceInfo* _Nonnull)camera withCompletionHandler:(void (^ _Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( switchSource(camera:completionHandler:));
// Class extension ends for LocalVideoStream.

@end

/// Information about a video device
NS_SWIFT_NAME(VideoDeviceInfo)
@interface ACSVideoDeviceInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get the name of this video device.
@property (retain, nonnull, readonly) NSString * name;

/// Get Name of this audio device.
@property (retain, nonnull, readonly) NSString * id;

/// Direction of the camera
@property (readonly) ACSCameraFacing cameraFacing;

/// Get the Device Type of this video device.
@property (readonly) ACSVideoDeviceType deviceType;

@end

/// Property bag class for Audio Options. Use this class to set audio settings required during a call (start/join)
NS_SWIFT_NAME(AudioOptions)
@interface ACSAudioOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Start an outgoing or accept incoming call muted (true) or un-muted(false)
@property BOOL muted;

@end

/// Options to be passed when joining a call
NS_SWIFT_NAME(JoinCallOptions)
@interface ACSJoinCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when placing a call
@property (retain, nullable) ACSVideoOptions * videoOptions;

/// Audio options when placing a call
@property (retain, nullable) ACSAudioOptions * audioOptions;


@end

/// Options to be passed when accepting a call
NS_SWIFT_NAME(AcceptCallOptions)
@interface ACSAcceptCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when accepting a call
@property (retain, nonnull) ACSVideoOptions * videoOptions;

@end

/// Options to be passed when starting a call
NS_SWIFT_NAME(StartCallOptions)
@interface ACSStartCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video options when starting a call
@property (retain, nullable) ACSVideoOptions * videoOptions;

/// Audio options when starting a call
@property (retain, nullable) ACSAudioOptions * audioOptions;

// Class extension begins for StartCallOptions.
@property(nonatomic, nonnull) PhoneNumberIdentifier* alternateCallerId;
// Class extension ends for StartCallOptions.

@end

/// Options when making an outgoing PSTN call
NS_SWIFT_NAME(AddPhoneNumberOptions)
@interface ACSAddPhoneNumberOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

// Class extension begins for AddPhoneNumberOptions.
@property(nonatomic, nonnull) PhoneNumberIdentifier* alternateCallerId;
// Class extension ends for AddPhoneNumberOptions.

@end

/// JoinMeetingLocator super type, locator for joining meetings
NS_SWIFT_NAME(JoinMeetingLocator)
@interface ACSJoinMeetingLocator : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

@end

/// Options for joining a group call
NS_SWIFT_NAME(GroupCallLocator)
@interface ACSGroupCallLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSUUID * _Nonnull )groupId NS_SWIFT_NAME( init(groupId:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The unique identifier for the group conversation
@property (retain, nonnull, readonly) NSUUID *groupId;

@end

/// Options for joining a Teams meeting using Coordinates locator
NS_SWIFT_NAME(TeamsMeetingCoordinatesLocator)
@interface ACSTeamsMeetingCoordinatesLocator : ACSJoinMeetingLocator
-(nonnull instancetype)initWithThreadId:(NSString * _Nonnull )threadId organizerId:(NSUUID * _Nonnull )organizerId tenantId:(NSUUID * _Nonnull )tenantId messageId:(NSString * _Nonnull )messageId NS_SWIFT_NAME( init(withThreadId:organizerId:tenantId:messageId:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The thread identifier of meeting
@property (retain, nonnull, readonly) NSString * threadId;

/// The organizer identifier of meeting
@property (retain, nonnull, readonly) NSUUID *organizerId;

/// The tenant identifier of meeting
@property (retain, nonnull, readonly) NSUUID *tenantId;

/// The message identifier of meeting
@property (retain, nonnull, readonly) NSString * messageId;

@end

/// Options for joining a Teams meeting using Link locator
NS_SWIFT_NAME(TeamsMeetingLinkLocator)
@interface ACSTeamsMeetingLinkLocator : ACSJoinMeetingLocator
-(nonnull instancetype)init:(NSString * _Nonnull )meetingLink NS_SWIFT_NAME( init(meetingLink:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// The URI of the meeting
@property (retain, nonnull, readonly) NSString * meetingLink;

@end

/// Describes the Caller Information
NS_SWIFT_NAME(CallerInfo)
@interface ACSCallerInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The display name of the caller
@property (retain, nonnull, readonly) NSString * displayName;

// Class extension begins for CallerInfo.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for CallerInfo.

@end

/// Describes an incoming call
NS_SWIFT_NAME(PushNotificationInfo)
@interface ACSPushNotificationInfo : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The display name of the caller
@property (retain, nonnull, readonly) NSString * fromDisplayName;

/// Indicates whether the incoming call has a video or not
@property (readonly) BOOL incomingWithVideo;

// Class extension begins for PushNotificationInfo.
@property (retain, readonly, nonnull) id<CommunicationIdentifier> from;
@property (retain, readonly, nonnull) id<CommunicationIdentifier> to;
@property (nonatomic, readonly, nonnull) NSUUID* callId;
+(ACSPushNotificationInfo* _Nonnull) fromDictionary:(NSDictionary* _Nonnull)payload;
// Class extension ends for PushNotificationInfo.

@end

/// Options for creating CallAgent
NS_SWIFT_NAME(CallAgentOptions)
@interface ACSCallAgentOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Specify the display name of the local participant for all new calls
@property (retain, nonnull) NSString * displayName;

/// Emergency call options when creating a call agent
@property (retain, nullable) ACSEmergencyCallOptions * emergencyCallOptions;

@end

/// Options for emergency call of call agent
NS_SWIFT_NAME(EmergencyCallOptions)
@interface ACSEmergencyCallOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Specify the ISO 3166-1 alpha-2 emergency country code of the local participant for emergency calls
@property (retain, nonnull) NSString * countryCode;

@end

/// Call agent created by the CallClient factory method createCallAgent It bears the responsibility of managing calls on behalf of the authenticated user
NS_SWIFT_NAME(CallAgent)
@interface ACSCallAgent : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Returns the list of all active calls.
@property (copy, nonnull, readonly) NSArray<ACSCall *> * calls;

/**
 * The delegate that will handle events from the ACSCallAgent.
 */
@property(nonatomic, weak, nullable) id<ACSCallAgentDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSCallAgent.
 */
@property(nonatomic, strong, nonnull, readonly) ACSCallAgentEvents *events;

/// Releases all the resources held by CallAgent. CallAgent should be destroyed/nullified after dispose.
-(void)dispose;

/// Unregister all previously registered devices from receiving incoming calls push notifications.
-(void)unregisterPushNotificationWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( unregisterPushNotification(completionHandler:));

// Class extension begins for CallAgent.
-(void)startCall:(NSArray<id<CommunicationIdentifier>>* _Nonnull)participants
            options:(ACSStartCallOptions* _Nullable)options
withCompletionHandler:(void (^ _Nonnull)(ACSCall* _Nullable call, NSError* _Nullable error))completionHandler NS_SWIFT_NAME( startCall(participants:options:completionHandler:));
-(void)joinWithMeetingLocator:(ACSJoinMeetingLocator* _Nonnull)meetingLocator
              joinCallOptions:(ACSJoinCallOptions* _Nullable)joinCallOptions
withCompletionHandler:(void (^ _Nonnull)(ACSCall* _Nullable call, NSError* _Nullable error))completionHandler NS_SWIFT_NAME( join(with:joinCallOptions:completionHandler:));
-(void)registerPushNotifications: (NSData* _Nonnull)deviceToken withCompletionHandler:(void (^ _Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( registerPushNotifications(deviceToken:completionHandler:));
-(void)handlePushNotification:(ACSPushNotificationInfo* _Nonnull)notification withCompletionHandler:(void (^_Nonnull)(NSError* _Nullable error))completionHandler NS_SWIFT_NAME( handlePush(notification:completionHandler:));
// Class extension ends for CallAgent.

@end

/// Describes a call
NS_SWIFT_NAME(Call)
@interface ACSCall : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get a list of remote participants in the current call. In case of calls with participants of hundred or more, only media active participants are present in this collection.
@property (copy, nonnull, readonly) NSArray<ACSRemoteParticipant *> * remoteParticipants;

/// Id of the call
@property (retain, nonnull, readonly) NSString * id;

/// Current state of the call
@property (readonly) ACSCallState state;

/// Containing code/subcode indicating how a call has ended
@property (retain, nonnull, readonly) ACSCallEndReason * callEndReason;

/// Outgoing or Incoming depending on the Call Direction
@property (readonly) ACSCallDirection direction;

/// Whether the local microphone is muted or not.
@property (readonly) BOOL isMuted;

/// The identity of the caller
@property (retain, nonnull, readonly) ACSCallerInfo * callerInfo;

/// Get a list of local video streams in the current call.
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * localVideoStreams;

/**
 * The delegate that will handle events from the ACSCall.
 */
@property(nonatomic, weak, nullable) id<ACSCallDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSCall.
 */
@property(nonatomic, strong, nonnull, readonly) ACSCallEvents *events;

/// Mute local microphone.
-(void)muteWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( mute(completionHandler:));

/// Unmute local microphone.
-(void)unmuteWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( unmute(completionHandler:));

/// Send DTMF tone
-(void)sendDtmf:(ACSDtmfTone)tone withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( sendDtmf(tone:completionHandler:));

/// Start sharing video stream to the call
-(void)startVideo:(ACSLocalVideoStream * _Nonnull )stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( startVideo(stream:completionHandler:));

/// Stop sharing video stream to the call
-(void)stopVideo:(ACSLocalVideoStream * _Nonnull )stream withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( stopVideo(stream:completionHandler:));

/// HangUp a call
-(void)hangUp:(ACSHangUpOptions * _Nullable )options withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( hangUp(options:completionHandler:));

/// Remove a participant from a call
-(void)removeParticipant:(ACSRemoteParticipant * _Nonnull )participant withCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( remove(participant:completionHandler:));

/// Hold this call
-(void)holdWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( hold(completionHandler:));

/// Resume this call
-(void)resumeWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( resume(completionHandler:));

// Class extension begins for Call.
-(ACSRemoteParticipant* _Nullable)addParticipant:(id<CommunicationIdentifier> _Nonnull)participant withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( add(participant:));
-(ACSRemoteParticipant* _Nullable)addParticipant:(PhoneNumberIdentifier* _Nonnull) participant options:(ACSAddPhoneNumberOptions* _Nullable)options withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( add(participant:options:));

-(id _Nonnull)feature: (Class _Nonnull)featureClass NS_REFINED_FOR_SWIFT;
// Class extension ends for Call.

@end

/// Describes a remote participant on a call
NS_SWIFT_NAME(RemoteParticipant)
@interface ACSRemoteParticipant : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Private Preview Only: Display Name of the remote participant
@property (retain, nonnull, readonly) NSString * displayName;

/// True if the remote participant is muted
@property (readonly) BOOL isMuted;

/// True if the remote participant is speaking. Only applicable to multi-party calls
@property (readonly) BOOL isSpeaking;

/// Reason why participant left the call, contains code/subcode.
@property (retain, nonnull, readonly) ACSCallEndReason * callEndReason;

/// Current state of the remote participant
@property (readonly) ACSParticipantState state;

/// Remote Video streams part of the current call
@property (copy, nonnull, readonly) NSArray<ACSRemoteVideoStream *> * videoStreams;

/**
 * The delegate that will handle events from the ACSRemoteParticipant.
 */
@property(nonatomic, weak, nullable) id<ACSRemoteParticipantDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSRemoteParticipant.
 */
@property(nonatomic, strong, nonnull, readonly) ACSRemoteParticipantEvents *events;

// Class extension begins for RemoteParticipant.
@property(nonatomic, readonly, nonnull) id<CommunicationIdentifier> identifier;
// Class extension ends for RemoteParticipant.

@end

/// Describes the reason for a call to end
NS_SWIFT_NAME(CallEndReason)
@interface ACSCallEndReason : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// The code
@property (readonly) int code;

/// The subcode
@property (readonly) int subcode;

@end

/// Video stream on remote participant
NS_SWIFT_NAME(RemoteVideoStream)
@interface ACSRemoteVideoStream : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// True when remote video stream is available.
@property (readonly) BOOL isAvailable;

/// MediaStream type of the current remote video stream (Video or ScreenShare).
@property (readonly) ACSMediaStreamType mediaStreamType;

/// Unique Identifier of the current remote video stream.
@property (readonly) int id;


@end

/// Describes a PropertyChanged event data
NS_SWIFT_NAME(PropertyChangedEventArgs)
@interface ACSPropertyChangedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

@end

/// Information about remote video streams added or removed
NS_SWIFT_NAME(RemoteVideoStreamsEventArgs)
@interface ACSRemoteVideoStreamsEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Remote video streams that have been added to the current call
@property (copy, nonnull, readonly) NSArray<ACSRemoteVideoStream *> * addedRemoteVideoStreams;

/// Remote video streams that are no longer part of the current call
@property (copy, nonnull, readonly) NSArray<ACSRemoteVideoStream *> * removedRemoteVideoStreams;

@end

/// Describes a ParticipantsUpdated event data
NS_SWIFT_NAME(ParticipantsUpdatedEventArgs)
@interface ACSParticipantsUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// List of Participants that were added
@property (copy, nonnull, readonly) NSArray<ACSRemoteParticipant *> * addedParticipants;

/// List of Participants that were removed
@property (copy, nonnull, readonly) NSArray<ACSRemoteParticipant *> * removedParticipants;

@end

/// Describes a LocalVideoStreamsUpdated event data
NS_SWIFT_NAME(LocalVideoStreamsUpdatedEventArgs)
@interface ACSLocalVideoStreamsUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// List of LocalVideoStream that were added
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * addedStreams;

/// List of LocalVideoStream that were removed
@property (copy, nonnull, readonly) NSArray<ACSLocalVideoStream *> * removedStreams;

@end

/// Property bag class for hanging up a call
NS_SWIFT_NAME(HangUpOptions)
@interface ACSHangUpOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Use to determine whether the current call should be terminated for all participant on the call or not
@property BOOL forEveryone;

@end

/// CallFeature super type, features extensions for call.
NS_SWIFT_NAME(CallFeature)
@interface ACSCallFeature : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Name of the extended CallFeature.
@property (retain, nonnull, readonly) NSString * name;

@end

/// Describes a CallsUpdated event
NS_SWIFT_NAME(CallsUpdatedEventArgs)
@interface ACSCallsUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// New calls being tracked by the library
@property (copy, nonnull, readonly) NSArray<ACSCall *> * addedCalls;

/// Calls that are no longer tracked by the library
@property (copy, nonnull, readonly) NSArray<ACSCall *> * removedCalls;

@end

/// Describes an incoming call
NS_SWIFT_NAME(IncomingCall)
@interface ACSIncomingCall : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Describe the reason why a call has ended
@property (retain, nullable, readonly) ACSCallEndReason * callEndReason;

/// Information about the caller
@property (retain, nonnull, readonly) ACSCallerInfo * callerInfo;

/// Id of the call
@property (retain, nonnull, readonly) NSString * id;

/// Is inoming video enabled
@property (readonly) BOOL isVideoEnabled;

/**
 * The delegate that will handle events from the ACSIncomingCall.
 */
@property(nonatomic, weak, nullable) id<ACSIncomingCallDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSIncomingCall.
 */
@property(nonatomic, strong, nonnull, readonly) ACSIncomingCallEvents *events;

/// Accept an incoming call
-(void)accept:(ACSAcceptCallOptions * _Nonnull )options withCompletionHandler:(void (^ _Nonnull )(ACSCall * _Nullable  value, NSError * _Nullable error))completionHandler NS_SWIFT_NAME( accept(options:completionHandler:));

/// Reject this incoming call
-(void)rejectWithCompletionHandler:(void (^ _Nonnull )(NSError * _Nullable error))completionHandler NS_SWIFT_NAME( reject(completionHandler:));

@end

/// This is the main class representing the entrypoint for the Calling SDK.
NS_SWIFT_NAME(CallClient)
@interface ACSCallClient : NSObject
-(nonnull instancetype)init;

-(nonnull instancetype)init:(ACSCallClientOptions * _Nonnull )options NS_SWIFT_NAME( init(options:));

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Releases all the resources held by CallClient. CallClient should be destroyed/nullified after dispose.
-(void)dispose;

// Class extension begins for CallClient.

-(void)createCallAgent:(CommunicationTokenCredential* _Nonnull) userCredential
 withCompletionHandler:(void (^ _Nonnull)(ACSCallAgent* _Nullable clientAgent,
                                          NSError * _Nullable error))completionHandler NS_SWIFT_NAME( createCallAgent(userCredential:completionHandler:));

-(void)createCallAgentWithOptions:(CommunicationTokenCredential* _Nonnull) userCredential
                 callAgentOptions:(ACSCallAgentOptions* _Nullable) callAgentOptions
            withCompletionHandler:(void (^ _Nonnull)(ACSCallAgent* _Nullable clientAgent,
                                                     NSError* _Nullable error))completionHandler NS_SWIFT_NAME( createCallAgent(userCredential:options:completionHandler:));

-(void)getDeviceManagerWithCompletionHandler:(void (^ _Nonnull)(ACSDeviceManager* _Nullable value,
                                                                NSError* _Nullable error))completionHandler NS_SWIFT_NAME( getDeviceManager(completionHandler:));

@property (retain, nonnull) CommunicationTokenCredential* communicationCredential;
// Class extension ends for CallClient.

@end

/// Options to be passed when creating a call client
NS_SWIFT_NAME(CallClientOptions)
@interface ACSCallClientOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Call Diagnostics options when creating a call client
@property (retain, nullable) ACSCallDiagnosticsOptions * diagnostics;

@end

/// Options for diagnostics of call client
NS_SWIFT_NAME(CallDiagnosticsOptions)
@interface ACSCallDiagnosticsOptions : NSObject
-(nonnull instancetype)init;

/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// An Identifier to group together multiple appIds into small bundle, invariant of version.
@property (retain, nonnull) NSString * appName;

/// The application version.
@property (retain, nonnull) NSString * appVersion;

/// Tags - additonal information.
@property (copy, nonnull) NSArray<NSString *> * tags;

@end

/// Device manager
NS_SWIFT_NAME(DeviceManager)
@interface ACSDeviceManager : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Get the list of currently connected video devices
@property (copy, nonnull, readonly) NSArray<ACSVideoDeviceInfo *> * cameras;

/**
 * The delegate that will handle events from the ACSDeviceManager.
 */
@property(nonatomic, weak, nullable) id<ACSDeviceManagerDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSDeviceManager.
 */
@property(nonatomic, strong, nonnull, readonly) ACSDeviceManagerEvents *events;

@end

/// Describes a VideoDevicesUpdated event data
NS_SWIFT_NAME(VideoDevicesUpdatedEventArgs)
@interface ACSVideoDevicesUpdatedEventArgs : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Video devicesRemote video streams that have been added to the current call
@property (copy, nonnull, readonly) NSArray<ACSVideoDeviceInfo *> * addedVideoDevices;

/// Remote video streams that have been added to the current call
@property (copy, nonnull, readonly) NSArray<ACSVideoDeviceInfo *> * removedVideoDevices;

@end

/// Call Feature for managing call recording
NS_SWIFT_NAME(RecordingCallFeature)
@interface ACSRecordingCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Indicates if recording is active in current call
@property (readonly) BOOL isRecordingActive;

/**
 * The delegate that will handle events from the ACSRecordingCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSRecordingCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSRecordingCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSRecordingCallFeatureEvents *events;

@end

/// Call Feature for managing call transcription
NS_SWIFT_NAME(TranscriptionCallFeature)
@interface ACSTranscriptionCallFeature : ACSCallFeature
-(nonnull instancetype)init NS_UNAVAILABLE;
/// Indicates if transcription is active in current call
@property (readonly) BOOL isTranscriptionActive;

/**
 * The delegate that will handle events from the ACSTranscriptionCallFeature.
 */
@property(nonatomic, weak, nullable) id<ACSTranscriptionCallFeatureDelegate> delegate;

/**
 * The events will register blocks to handle events from the ACSTranscriptionCallFeature.
 */
@property(nonatomic, strong, nonnull, readonly) ACSTranscriptionCallFeatureEvents *events;

@end

/// Options to be passed when rendering a Video
NS_SWIFT_NAME(CreateViewOptions)
@interface ACSCreateViewOptions : NSObject
-(nonnull instancetype)init:(ACSScalingMode)scalingMode NS_SWIFT_NAME( init(scalingMode:));

-(nonnull instancetype)init NS_UNAVAILABLE;
/// Deallocates the memory occupied by this object.
-(void)dealloc;

/// Scaling mode for rendering the video.
@property ACSScalingMode scalingMode;

@end

