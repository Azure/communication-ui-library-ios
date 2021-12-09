//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSVideoStreamRenderer.h
//
//------------------------------------------------------------------------------

#import "ACSVideoStreamRendererView.h"
#import "ACSStreamSize.h"

@class ACSLocalVideoStream;
@class ACSCreateViewOptions;
@class ACSRemoteVideoStream;

@class ACSVideoStreamRenderer;

NS_SWIFT_NAME(RendererDelegate)
@protocol ACSVideoStreamRendererDelegate <NSObject>
- (void)rendererFailedToStart:(ACSVideoStreamRenderer* _Nonnull) renderer NS_SWIFT_NAME( videoStreamRenderer(didFailToStart:));
@optional
- (void)onFirstFrameRendered:(ACSVideoStreamRenderer* _Nonnull) renderer NS_SWIFT_NAME( videoStreamRenderer(didRenderFirstFrame:));
@end

NS_SWIFT_NAME(VideoStreamRenderer)
@interface ACSVideoStreamRenderer : NSObject
-(nonnull instancetype)init NS_UNAVAILABLE;
-(instancetype _Nonnull)initWithLocalVideoStream:(ACSLocalVideoStream*_Nonnull) localVideoStream
                                       withError:(NSError*_Nullable*_Nonnull) nonnull_error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( init(localVideoStream:));
-(instancetype _Nonnull)initWithRemoteVideoStream:(ACSRemoteVideoStream*_Nonnull) remoteVideoStream
                                        withError:(NSError*_Nullable*_Nonnull) nonnull_error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( init(remoteVideoStream:));
-(ACSVideoStreamRendererView* _Nonnull)createView:(NSError*_Nullable*_Nonnull) nonnull_error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( createView());
-(ACSVideoStreamRendererView* _Nonnull)createViewWithOptions:(ACSCreateViewOptions*_Nullable) options
                                        withError:(NSError*_Nullable*_Nonnull) error __attribute__((swift_error(nonnull_error))) NS_SWIFT_NAME( createView(withOptions:));
-(void)dispose;

@property(readonly) struct ACSStreamSize size;
@property(nonatomic, assign, nullable) id<ACSVideoStreamRendererDelegate> delegate;

@end
