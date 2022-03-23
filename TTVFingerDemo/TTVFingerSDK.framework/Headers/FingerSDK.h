//
//  face_sdk_wrapper.h
//  Face Detect
//
//  Created by Admin on 2/8/21.
//  Copyright © 2021 Sunyard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FingerTemplate : NSObject

@property (nonatomic) int quality;
@property (nonatomic) int nfiqScore;
@property (nonatomic) int location;
@property (atomic) NSData* feature;
@end

@interface FingerSDK : NSObject
+(FingerSDK*) getInstance;

-(int) initSDK;
-(void) initCapture;
-(double) getCaptureQuality: (UIImage*) image;
-(NSMutableArray*) captureFinger: (UIImage*) image;
-(double) compareFeature:(FingerTemplate*) feat1 feat2:(FingerTemplate*) feat2;

@end

NS_ASSUME_NONNULL_END
