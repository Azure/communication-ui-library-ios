//+-----------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// Module name : ACSVideoStreamRendererView.h
//
//------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forward declaration as importing here causes cyclic dependency
typedef NS_ENUM(NSInteger, ACSScalingMode);

NS_SWIFT_NAME(RendererView)
@interface ACSVideoStreamRendererView : UIView
-(nonnull instancetype)init NS_UNAVAILABLE;
-(void)updateScalingMode:(ACSScalingMode) scalingMode NS_SWIFT_NAME( update(scalingMode:));
-(void)dispose;
-(bool)isRendering;
@end
