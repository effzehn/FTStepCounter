//
//  FTStepCountController.h
//
//  Created by Andre Hoffmann on 18.02.14.
//  Copyright (c) 2014 Andre Hoffmann. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: enable background fetching job so no step gets lost – since the M7 only records data for up to 7 days.


@protocol FTStepCountControllerDelegate;

@interface FTStepCountController : NSObject

@property (nonatomic) NSUInteger steps;
@property (nonatomic) BOOL isCounting;
@property (nonatomic) id<FTStepCountControllerDelegate> delegate;

+ (instancetype)sharedStepCountController;

- (id)initWithResetCount:(BOOL)reset startImmediately:(BOOL)start onQueue:(NSOperationQueue *)queue;


- (BOOL)start;
- (BOOL)stop;
- (void)resetCount;

@end



@protocol FTStepCountControllerDelegate <NSObject>

@required

- (void)stepCountControllerDidUpdateSteps:(NSUInteger)steps;
- (void)stepCountControllerDidFailWithError:(NSError *)error;

@end