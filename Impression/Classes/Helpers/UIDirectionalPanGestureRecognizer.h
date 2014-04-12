//
//  UIDirectionalPanGestureRecognizer.h
//  Impression
//
//  Created by Jason Fieldman on 4/12/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	PAN_DIR_UNKNOWN = 0,
	PAN_DIR_VERTICAL,
	PAN_DIR_HORIZONTAL,
} PanDirection_t;

@interface UIDirectionalPanGestureRecognizer : UIPanGestureRecognizer <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) PanDirection_t direction;

@end
