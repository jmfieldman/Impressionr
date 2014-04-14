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

@interface MainViewController : UIViewController <SettingsManagerDelegate, FPSDelegate> {
	/* Painting view */
	ImpressionPainterView *_paintView;
	
	/* Touch handler */
	UIView *_gesturePad;
	
	/* Controls */
	UIButton *_lineSettingsButton;
	UIButton *_fieldSettingsButton;
	UIButton *_colorSettingsButton;
	
	/* But cancel button behind all UI */
	UIButton *_cancelButton;
	
	/* FPS Display */
	UIView   *_fpsLabelContainer;
	UILabel  *_fpsLabel;
	
	/* Menus */
	UIView   *_currentlyDisplayedMenu;
	UIView   *_lineSettingsMenu;
	UIView   *_fieldSettingsMenu;
	
	/* Sliders */
	UISlider *_lineWidthSlider;
	UISlider *_lineCountSlider;
	UISlider *_lineSpeedSlider;
	UISlider *_lineAlphaSlider;
	
	UISlider *_fieldWeightSlider;
	UISlider *_fieldOffsetSlider;
	UISlider *_fieldScaleSlider;
	UIButton *_fieldResetButton;
		
	/* Info views */
	UILabel  *_lineWidthInfo;
	UILabel  *_lineCountInfo;
	UILabel  *_lineSpeedInfo;
	UILabel  *_lineAlphaInfo;
	
	UILabel  *_fieldWeightInfo;
	UILabel  *_fieldOffsetInfo;
	UILabel  *_fieldScaleInfo;
	
	
	/* Dimensions */
	CGRect _lineSettingButtonFrame[2];
	CGRect _fieldSettingButtonFrame[2];
	CGRect _colorSettingButtonFrame[2];
}

SINGLETON_INTR(MainViewController);

@end
