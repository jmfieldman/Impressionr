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
	}
	return self;
}

- (void) handleOnePan:(UIDirectionalPanGestureRecognizer*)pan {
	CGPoint translation = [pan translationInView:_gesturePad];
	_paintView.lineSpeed -= translation.y / 1.0;
	NSLog(@"modifying by: %d %f", pan.direction, -translation.y / 1.0);
	[pan setTranslation:CGPointZero inView:_gesturePad];
}

- (void) handleTwoPan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleThreePan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleFourPan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleTwoRot:(UIRotationGestureRecognizer*)rot {
	
}

- (void) handleTwoPinch:(UIPinchGestureRecognizer*)pinch {
	
}

@end
