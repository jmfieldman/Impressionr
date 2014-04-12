//
//  MainViewController.h
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImpressionPainterView.h"
#import "UIDirectionalPanGestureRecognizer.h"

@interface MainViewController : UIViewController {
	/* Painting view */
	ImpressionPainterView *_paintView;
	
	/* Touch handler */
	UIView *_gesturePad;
}

SINGLETON_INTR(MainViewController);

@end
