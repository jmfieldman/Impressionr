//
//  MainViewController.h
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImpressionPainterView.h"

@interface MainViewController : UIViewController {
	ImpressionPainterView *_paintView;
}

SINGLETON_INTR(MainViewController);

@end
