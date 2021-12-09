//
//  ACSFeatures.h
//  AzureCommunicationCalling
//
//

#ifndef ACSFeatures_h
#define ACSFeatures_h

#import <Foundation/Foundation.h>
#import "AzureCommunicationCalling.h"

NS_SWIFT_NAME(Features)
@interface ACSFeatures : NSObject

@property (class, readonly) Class recording NS_REFINED_FOR_SWIFT;
@property (class, readonly) Class transcription NS_REFINED_FOR_SWIFT;

@end

#endif /* ACSFeatures_h */
