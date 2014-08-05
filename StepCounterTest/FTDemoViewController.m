//
//  FTDemoViewController.m
//
//  Created by Andre Hoffmann on 17.02.14.
//  Copyright (c) 2014 Andre Hoffmann. All rights reserved.
//

#import "FTDemoViewController.h"
#import "FTAppDelegate.h"
#import <CoreMotion/CoreMotion.h>

@interface FTDemoViewController ()

@property (nonatomic) FTStepCountController *stepCounter;
@property (nonatomic) CMMotionActivityManager *activityManager;

@end


@implementation FTDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.stepCounter = [[FTStepCountController alloc] initWithResetCount:NO
														startImmediately:YES
																 onQueue:[NSOperationQueue mainQueue]];
	
	self.stepCounter.delegate = self;
	
	if ([CMMotionActivityManager isActivityAvailable]) {
		self.activityManager = [[CMMotionActivityManager alloc] init];
		[self.activityManager startActivityUpdatesToQueue:[NSOperationQueue mainQueue]
											  withHandler:^(CMMotionActivity *activity) {
												  [self setActivityDisplayWithActivity:activity];
											  }];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSteps:(NSUInteger)steps
{
	_steps = steps;
	self.stepsLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.steps];
}

- (IBAction)resetCount:(id)sender
{
	self.stepsLabel.text = @"0";
	
	[self.stepCounter resetCount];
}


- (void)stepCountControllerDidUpdateSteps:(NSUInteger)steps
{
	self.steps = steps;
}

- (void)stepCountControllerDidFailWithError:(NSError *)error
{
	NSLog(@"StepCounter fail: %@", error.localizedDescription);
}

- (void)setActivityDisplayWithActivity:(CMMotionActivity *)activity
{
	NSMutableString *activityString = [[NSMutableString alloc] initWithString:@"Activities: "];
	
	if (activity.running) {
		[activityString appendString:@"Running "];
	}
	if (activity.stationary) {
		[activityString appendString:@"Stationary "];
	}
	if (activity.automotive) {
		[activityString appendString:@"Automotive "];
	}
	if (activity.walking) {
		[activityString appendString:@"Walking "];
	}
	if (activity.unknown) {
		[activityString appendString:@"Unknown"];
	}
	
	self.activityLabel.text = activityString;
	
	switch (activity.confidence) {
		case CMMotionActivityConfidenceLow:
			self.confidenceIndicator.backgroundColor = [UIColor redColor];
			break;
		case CMMotionActivityConfidenceMedium:
			self.confidenceIndicator.backgroundColor = [UIColor yellowColor];
			break;
		case CMMotionActivityConfidenceHigh:
			self.confidenceIndicator.backgroundColor = [UIColor greenColor];
			break;
		default:
			break;
	}
}

@end
