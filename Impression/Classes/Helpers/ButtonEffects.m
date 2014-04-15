//
//  ButtonEffects.m
//  ExperimentF
//
//  Created by Jason Fieldman on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ButtonEffects.h"


@implementation ButtonEffect
- (void) attachToControl:(UIControl*)control { }
@end




@implementation ButtonEffectsExpander
SINGLETON_IMPL(ButtonEffectsExpander);

- (void) attachToControl:(UIControl*)control {
	[control addTarget:self action:@selector(expandCheck:) forControlEvents:0xF33];
	[control addTarget:self action:@selector(contract:)    forControlEvents:0xC0];
	
	/* Sounds */
	[control addTarget:self action:@selector(playDown:)    forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragEnter];
	[control addTarget:self action:@selector(playUp:)      forControlEvents:UIControlEventTouchUpInside];
	[control addTarget:self action:@selector(playCancel:)  forControlEvents:UIControlEventTouchDragExit];
}

- (void) expandCheck:(id)sender {
	UIControl *control = (UIControl*)sender;
	if (control.highlighted) {
		control.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1);
		
		CALayer *layer = control.layer;
		CAKeyframeAnimation *animation;
		animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
		animation.duration = 0.15f;
		animation.cumulative = NO;
		animation.repeatCount = 1;
		animation.values = [NSArray arrayWithObjects:           // i.e., Rotation values for the 3 keyframes, in RADIANS
							[NSValue valueWithCATransform3D:CATransform3DIdentity],
							[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.4, 1.4, 1)],
							[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
							nil]; 
		animation.keyTimes = [NSArray arrayWithObjects:     // Relative timing values for the 3 keyframes
							  [NSNumber numberWithFloat:0], 
							  [NSNumber numberWithFloat:.5], 
							  [NSNumber numberWithFloat:1.0], nil]; 
		animation.timingFunctions = [NSArray arrayWithObjects:
									 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],        // from keyframe 1 to keyframe 2
									 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil]; // from keyframe 2 to keyframe 3
		[layer addAnimation:animation forKey:nil];
	} else {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1];
		control.layer.transform = CATransform3DIdentity;
		[UIView commitAnimations];
	}	
}


- (void) contract:(id)sender {
	UIControl *control = (UIControl*)sender;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1];
	[UIView setAnimationDelay:0.05];
	control.layer.transform = CATransform3DIdentity;
	[UIView commitAnimations];
}

- (void) playDown:(id)sender {
	//UIView *v = (UIView*)sender;
	//[v.superview bringSubviewToFront:v];

	[PreloadedSFX playSFX:PLSFX_BUTTON_DOWN];
}

- (void) playUp:(id)sender {
	[PreloadedSFX playSFX:PLSFX_BUTTON_UP];
}

- (void) playCancel:(id)sender {
	[PreloadedSFX playSFX:PLSFX_BUTTON_MENU];
}

@end
