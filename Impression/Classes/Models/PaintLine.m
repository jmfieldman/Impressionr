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
			
	/* Immediate death? */
	if (_lifeRemaining <= 0) return duration;
	
	/* Setup line properties */
	CGContextSetStrokeColorWithColor(context, _color.CGColor);
	CGContextSetLineWidth(context, _lineWidth);
	CGContextSetLineCap(context, kCGLineCapRound);
	
	/* How far have we moved? */
	NSTimeInterval timeMoved = MIN(duration, _lifeRemaining);
	
	/* New point */
	CGPoint newPoint = CGPointMake(_currentPosition.x + _speedVector.dx * timeMoved,
								   _currentPosition.y + _speedVector.dy * timeMoved);
	
	
	/* If this isn't the first draw, we need to clip out the previous segment overlap */
	BOOL clipped = NO;
	if (_firstDraw || !_needsClip) {
		_firstDraw = NO;
	} else {
		float half = _lineWidth / 2;
		clipped = YES;
		CGContextSaveGState(context);
		CGContextBeginPath(context);
		CGContextAddArc(context, _currentPosition.x, _currentPosition.y, _lineWidth/2, M_PI * 2, 0, YES);
		CGContextAddRect(context, CGRectUnion(CGRectMake(_currentPosition.x-half, _currentPosition.y-half, _lineWidth, _lineWidth),
											  CGRectMake(newPoint.x-half, newPoint.y-half, _lineWidth, _lineWidth)));
		CGContextClip(context);
	}
	
	/* Update line */
	CGContextMoveToPoint(context, _currentPosition.x, _currentPosition.y);
	CGContextAddLineToPoint(context, newPoint.x, newPoint.y);
    CGContextStrokePath(context);
	
	/* Determine excess time */
	NSTimeInterval excess = 0;
	if (_lifeRemaining < duration) {
		excess = duration - _lifeRemaining;
	}
	
	/* Kill off */
	_lifeRemaining -= duration;
	
	/* Move point */
	_currentPosition = newPoint;
	
	/* Restore state */
	if (clipped) {
		CGContextRestoreGState(context);
	}
	
	return excess;
}


@end
