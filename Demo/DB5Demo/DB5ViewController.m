//
//  DB5ViewController.m
//  DB5Demo
//
//  Created by Brent Simmons on 6/26/13.
//  Copyright (c) 2013 Q Branch LLC. All rights reserved.
//

#import "DB5ViewController.h"
#import "VSTheme.h"


@interface DB5ViewController ()

@property (nonatomic, strong) VSTheme *theme;

@end


@implementation DB5ViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil theme:(VSTheme *)theme {

	self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self == nil)
		return nil;

	_theme = theme;

	return self;
}


- (void)viewDidLoad {

	self.view.backgroundColor = [self.theme colorForKey:@"backgroundColor"];
	
	UIView *square = [self.theme viewWithViewSpecifierKey:@"square"];
	[self.view addSubview:square];
	
	UILabel *label = [self.theme labelWithText:@"DB5 Demo App" specifierKey:@"label" sizeAdjustment:0];
	[self.view addSubview:label];
	
	[self.theme animateWithAnimationSpecifierKey:@"labelAnimation" animations:^{

		CGRect rLabel = label.frame;
		rLabel.origin = [self.theme pointForKey:@"labelFinalPosition"];

		label.frame = rLabel;
		
	} completion:^(BOOL finished) {
		NSLog(@"Ran an animation.");
	}];
}



@end
