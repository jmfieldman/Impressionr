//
//  PaintLine.h
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaintLine : NSObject

@property (nonatomic, assign)   CGPoint         currentPosition;
@property (nonatomic, assign)   CGVector        speedVector;
@property (nonatomic, assign)   CGFloat         lineWidth;
@property (nonatomic, assign)   NSTimeInterval  lifeRemaining;
@property (nonatomic, strong)   UIColor        *color;
@property (nonatomic, assign)   BOOL            firstDraw;
@property (nonatomic, assign)   BOOL            needsClip;


/* Draws the line for however much life is left; return the excess time */
- (NSTimeInterval) paintInContext:(CGContextRef)context forTimeDuration:(NSTimeInterval)duration;


@end
