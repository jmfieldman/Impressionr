//
//  UIDirectionalPanGestureRecognizer.m
//  Impression
//
//  Created by Jason Fieldman on 4/12/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "UIDirectionalPanGestureRecognizer.h"

@implementation UIDirectionalPanGestureRecognizer

- (id) initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		self.delegate = self;
	}
	return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	CGPoint translation = [self translationInView:self.view];
	_direction = ( fabs(translation.x) > fabs(translation.y) ) ? PAN_DIR_HORIZONTAL : PAN_DIR_VERTICAL;
	return YES;
}

@end
