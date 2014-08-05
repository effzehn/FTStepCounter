//
//  FTStepCountController.m
//
//  Created by Andre Hoffmann on 18.02.14.
//  Copyright (c) 2014 Andre Hoffmann. All rights reserved.
//

#import "FTStepCountController.h"

NSString *const kLastOpenDateKey = @"kFTStepCountContollerLastOpenDateKey";
NSString *const kTotalStepsKey = @"kFTStepCountContollerTotalStepsKey";

@import CoreMotion;

@interface FTStepCountController ()

@property (nonatomic) NSDate *lastMeasureDate;
@property (nonatomic) NSUInteger intermittentSteps;
@property (nonatomic) NSUInteger restoredSteps;
@property (nonatomic) CMStepCounter *stepCounter;
@property (nonatomic) NSOperationQueue *stepCountQueue;

@end


@implementation FTStepCountController

static FTStepCountController *sharedInstance = nil;


+ (instancetype)sharedStepCountController
{
	static FTStepCountController *sharedStepCountController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
		
        sharedStepCountController = [[self alloc] initWithResetCount:NO
													startImmediately:YES
															 onQueue:[NSOperationQueue mainQueue]];
    });
	
    return sharedStepCountController;
}


- (instancetype)initWithResetCount:(BOOL)reset startImmediately:(BOOL)start onQueue:(NSOperationQueue *)queue
{
	if (self == [super init]) {
		self.steps = 0;
		self.restoredSteps = 0;
		self.intermittentSteps = 0;
		self.isCounting = NO;
		self.stepCountQueue = queue;
		self.stepCounter = [[CMStepCounter alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(resume)
													 name:UIApplicationDidBecomeActiveNotification
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stop)
													 name:UIApplicationWillResignActiveNotification
												   object:nil];
		
		
		if (!reset) {		
			[self resume];
		}
		
		if (start) {
			[self start];
		}
	}
	
	return self;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (BOOL)retrieveIntermittentSteps
{
	self.lastMeasureDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastOpenDateKey];
	if (self.lastMeasureDate) {
		[self.stepCounter queryStepCountStartingFrom:self.lastMeasureDate
												  to:[NSDate date]
											 toQueue:self.stepCountQueue
										 withHandler:^(NSInteger numberOfSteps, NSError *error) {
											 if (error) {
												 [self updateWithError:error];
											 } else {
												 self.intermittentSteps = numberOfSteps;
												 [self updateDelegate];
											 }
										 }];
	} else {
		return NO;
	}
	
	return [self supportsStepCount];
}


- (BOOL)resume
{
	NSNumber *stepsFromDefaults = [[NSUserDefaults standardUserDefaults] objectForKey:kTotalStepsKey];
	if (stepsFromDefaults) {
		self.restoredSteps = [stepsFromDefaults unsignedIntegerValue];
	}
	
	[self retrieveIntermittentSteps];
	
	return [self start];
}


- (BOOL)start
{
	[self.stepCounter startStepCountingUpdatesToQueue:self.stepCountQueue
											 updateOn:2
										  withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
											  if (error) {
												  [self updateWithError:error];
											  } else {
												  self.isCounting = YES;
												  self.steps = self.restoredSteps + self.intermittentSteps + numberOfSteps;
											  }
										  }];
	
	return [self supportsStepCount];
}

- (BOOL)stop
{
	if (self.isCounting) {
		[self.stepCounter stopStepCountingUpdates];
		self.intermittentSteps = 0;
		self.isCounting = NO;
		
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastOpenDateKey];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:self.steps]
												  forKey:kTotalStepsKey];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		return YES;
	}
	
	return NO;
}


- (void)resetCount
{
	self.steps = 0;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:0]
											  forKey:kTotalStepsKey];
}


- (void)setSteps:(NSUInteger)steps
{
	_steps = steps;
	NSLog(@"Steps %lu", (unsigned long)self.steps);
	
	[self updateDelegate];
}


- (BOOL)supportsStepCount
{
	if (![CMStepCounter isStepCountingAvailable]) {
		NSLog(@"No step counting available!");
		
		return NO;
	}
	
	return YES;
}


- (void)updateDelegate
{
	if ([self.delegate conformsToProtocol:@protocol(FTStepCountControllerDelegate)] && self.delegate) {
		[self.delegate stepCountControllerDidUpdateSteps:self.steps];
	}
}

- (void)updateWithError:(NSError *)error
{
	if ([self.delegate conformsToProtocol:@protocol(FTStepCountControllerDelegate)] && self.delegate) {
		[self.delegate stepCountControllerDidFailWithError:error];
	}
}


@end
