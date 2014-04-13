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
#import "SettingsManager.h"

@interface MainViewController : UIViewController <SettingsManagerDelegate> {
	/* Painting view */
	ImpressionPainterView *_paintView;
	
	/* Touch handler */
	UIView *_gesturePad;
	
	/* Controls */
	UIButton *_lineSettingsButton;
	UIButton *_fieldSettingsButton;
	UIButton *_colorSettingsButton;
	
	/* Menus */
	UIView   *_lineSettingsMenu;
	
	/* Sliders */
	UISlider *_lineWidthSlider;
	
	/* Dimensions */
	CGRect _lineSettingButtonFrame[2];
	CGRect _fieldSettingButtonFrame[2];
	CGRect _colorSettingButtonFrame[2];
}

SINGLETON_INTR(MainViewController);

@end
