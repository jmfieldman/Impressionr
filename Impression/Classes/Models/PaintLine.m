//
//  PaintLine.m
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "PaintLine.h"

@implementation PaintLine



- (NSTimeInterval) paintInContext:(CGContextRef)context forTimeDuration:(NSTimeInterval)duration {
	
	/* Setup line properties */
	CGContextSetStrokeColorWithColor(context, _color.CGColor);
	CGContextSetLineWidth(context, _lineWidth);
	CGContextSetLineCap(context, kCGLineCapRound);
	
	/* Draw line */
	CGContextMoveToPoint(context, _currentPosition.x, _currentPosition.y);
	
	/* How far have we moved? */
	NSTimeInterval timeMoved = MIN(duration, _lifeRemaining);
	
	/* New point */
	CGPoint newPoint = CGPointMake(_currentPosition.x + _speedVector.dx * timeMoved,
								   _currentPosition.y + _speedVector.dy * timeMoved);
	
	_currentPosition = newPoint;
	
	/* Update line */
	CGContextAddLineToPoint(context, _currentPosition.x, _currentPosition.y);
    CGContextStrokePath(context);
	
	/* Determine excess time */
	NSTimeInterval excess = 0;
	if (_lifeRemaining < duration) {
		excess = duration - _lifeRemaining;
	}
	
	/* Kill off */
	_lifeRemaining -= duration;
	
	return excess;
}


@end
