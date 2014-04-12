//
//  MainViewController.m
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

/* Screen Gestures

 one   finger pan    vertical         - line speed
 one   finger pan    horizontal       - line width
 
 two   finger pan    vertical         - line count
 two   finger pan    horizontal       - line alpha
 
 three finger pan    vertical         - angle field scale
 three finger pan    horizontal       - angle field weight
 
 two   finger pinch                   - tint strength
 two   finger rotate                  - tint hue
 
 four  finger pan    vertical         - grain opacity
 four  finger pan    horizontal       - saturation
 
*/

@implementation MainViewController

SINGLETON_IMPL(MainViewController);

- (id)init {
	if ((self = [super init])) {
		
		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor redColor];
		
		_gesturePad = [[UIView alloc] initWithFrame:self.view.bounds];
		_gesturePad.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_gesturePad];
		
		_paintView = [[ImpressionPainterView alloc] initWithFrame:self.view.bounds];
		_paintView.image = [UIImage imageNamed:@"test_image1.jpg"];
		_paintView.painting = YES;
		_paintView.opaque = YES;
		_paintView.userInteractionEnabled = NO;
		[self.view addSubview:_paintView];
		
		
		/* Register gesture handlers */
		UIDirectionalPanGestureRecognizer *onePanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnePan:)];
		onePanVert.minimumNumberOfTouches = onePanVert.maximumNumberOfTouches = 1;
		[_gesturePad addGestureRecognizer:onePanVert];
		
		UIDirectionalPanGestureRecognizer *twoPanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoPan:)];
		twoPanVert.minimumNumberOfTouches = twoPanVert.maximumNumberOfTouches = 2;
		[_gesturePad addGestureRecognizer:twoPanVert];
		
		UIDirectionalPanGestureRecognizer *threePanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreePan:)];
		threePanVert.minimumNumberOfTouches = threePanVert.maximumNumberOfTouches = 3;
		[_gesturePad addGestureRecognizer:threePanVert];
		
		UIDirectionalPanGestureRecognizer *fourPanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFourPan:)];
		fourPanVert.minimumNumberOfTouches = fourPanVert.maximumNumberOfTouches = 4;
		[_gesturePad addGestureRecognizer:fourPanVert];
		
		UIRotationGestureRecognizer *twoRot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoRot:)];
		[_gesturePad addGestureRecognizer:twoRot];
		
		UIPinchGestureRecognizer *twoPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoPinch:)];
		[_gesturePad addGestureRecognizer:twoPinch];
		
		/* Register for settings */
		[[SettingsManager sharedInstance] addDelegate:self];
	}
	return self;
}


#pragma mark UIGestureRecognizerDelegate methods

- (void) handleOnePan:(UIDirectionalPanGestureRecognizer*)pan {
	CGPoint translation = [pan translationInView:_gesturePad];
	if (pan.direction == PAN_DIR_HORIZONTAL) {
		[SettingsManager sharedInstance].lineWidth += translation.x / (self.view.bounds.size.width/2);
	} else if (pan.direction == PAN_DIR_VERTICAL) {
		[SettingsManager sharedInstance].lineSpeed -= translation.y / (self.view.bounds.size.height/2);
	}
	
	[pan setTranslation:CGPointZero inView:_gesturePad];
}

- (void) handleTwoPan:(UIDirectionalPanGestureRecognizer*)pan {
	CGPoint translation = [pan translationInView:_gesturePad];
	if (pan.direction == PAN_DIR_HORIZONTAL) {
		[SettingsManager sharedInstance].lineAlpha += translation.x / (self.view.bounds.size.width/2);
	} else if (pan.direction == PAN_DIR_VERTICAL) {
		[SettingsManager sharedInstance].lineCount -= translation.y / (self.view.bounds.size.height/2);
	}
	
	[pan setTranslation:CGPointZero inView:_gesturePad];
}

- (void) handleThreePan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleFourPan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleTwoRot:(UIRotationGestureRecognizer*)rot {
	[SettingsManager sharedInstance].tintHue += rot.rotation;
	rot.rotation = 0;
}

- (void) handleTwoPinch:(UIPinchGestureRecognizer*)pinch {
	[SettingsManager sharedInstance].tintStrength += pinch.scale - 1;
	pinch.scale = 1;
}


#pragma mark SettingsManagerDelegate methods


- (void) settingLineWidthChangedTo:(float)slider actual:(float)width {
	_paintView.lineWidth = width;
}

- (void) settingLineSpeedChangedTo:(float)slider actual:(float)speed {
	_paintView.lineSpeed = speed;
}

- (void) settingLineCountChangedTo:(float)slider actual:(int)count {
	_paintView.lineCount = count;
}

- (void) settingLineAlphaChangedTo:(float)slider actual:(float)alpha {
	_paintView.lineAlpha = alpha;
}

- (void) settingAngleFieldScaleChangedTo:(float)slider actual:(float)scale {
	
}

- (void) settingAngleFieldWeightChangedTo:(float)slider actual:(float)weight {
	
}

- (void) settingTintStrengthChangedTo:(float)slider actual:(float)strength {
	NSLog(@"set strength: %f", strength);
	_paintView.colorTintStrength = strength;
}

- (void) settingTintHueChangedTo:(float)slider actual:(float)hue {
	_paintView.colorHue = hue;
}

- (void) settingSaturationChangedTo:(float)slider actual:(float)saturation {
	
}

- (void) settingGrainOpacityChangedTo:(float)slider actual:(float)grain {
	
}


@end
