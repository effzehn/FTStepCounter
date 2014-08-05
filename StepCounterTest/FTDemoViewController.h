//
//  FTDemoViewController.h
//
//  Created by Andre Hoffmann on 17.02.14.
//  Copyright (c) 2014 Andre Hoffmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTStepCountController.h"

@interface FTDemoViewController : UIViewController <FTStepCountControllerDelegate>

@property (nonatomic) NSUInteger steps;

@property (nonatomic) IBOutlet UILabel *stepsLabel;
@property (nonatomic) IBOutlet UILabel *activityLabel;
@property (nonatomic) IBOutlet UIButton *resetButton;
@property (nonatomic) IBOutlet UIView *confidenceIndicator;

- (IBAction)resetCount:(id)sender;

@end
