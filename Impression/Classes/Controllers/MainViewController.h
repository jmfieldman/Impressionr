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

@interface MainViewController : UIViewController <SettingsManagerDelegate, FPSDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
	/* Painting view */
	ImpressionPainterView *_paintView;
	
	/* Touch handler */
	UIView *_gesturePad;
	
	/* Controls */
	UIButton *_lineSettingsButton;
	UIButton *_fieldSettingsButton;
	UIButton *_colorSettingsButton;
	UIButton *_playPauseButton;
	UIButton *_originalButton;
	UIButton *_loadButton;
	UIButton *_saveButton;
	UIButton *_reloadButton;
	
	/* But cancel button behind all UI */
	UIButton *_cancelButton;
	
	/* FPS Display */
	UIView   *_fpsLabelContainer;
	UILabel  *_fpsLabel;
	
	/* Menus */
	UIView   *_currentlyDisplayedMenu;
	UIView   *_lineSettingsMenu;
	UIView   *_fieldSettingsMenu;
	UIView   *_colorSettingsMenu;
	UIView   *_loadMenu;
	UIView   *_saveMenu;
	UIView   *_savePurchaseMenu;
	
	float     _loadMenuHeight;
	float     _saveMenuHeight;
	float     _proMenuHeight;
	
	/* Modeal */
	UIView   *_modalMessageView;
	UILabel  *_modalMessageLabel;
	
	/* Sliders */
	UISlider *_lineWidthSlider;
	UISlider *_lineCountSlider;
	UISlider *_lineSpeedSlider;
	UISlider *_lineAlphaSlider;
	
	UISlider *_fieldWeightSlider;
	UISlider *_fieldOffsetSlider;
	UISlider *_fieldScaleSlider;
	UIButton *_fieldResetButton;
	
	UISlider *_colorStrengthSlider;
	UISlider *_colorHueSlider;
	UISlider *_colorSaturationSlider;
	UISlider *_colorGrainSlider;
		
	UIButton *_loadFromAlbum;
	UIButton *_loadFromRoll;
	UIButton *_loadFromCamera;
	UIButton *_loadFromClip;
	UIButton *_loadFromInsp;
	
	UIButton *_saveToAlbum;
	UIButton *_saveToClip;
	UIButton *_saveToFacebook;
	UIButton *_saveToInstagram;
	UIButton *_saveToOther;
	
	UIButton *_buyProButton;
	UIButton *_restorePurchaseButton;
	
	/* Info views */
	UILabel  *_lineWidthInfo;
	UILabel  *_lineCountInfo;
	UILabel  *_lineSpeedInfo;
	UILabel  *_lineAlphaInfo;
	
	UILabel  *_fieldWeightInfo;
	UILabel  *_fieldOffsetInfo;
	UILabel  *_fieldScaleInfo;
	
	UILabel  *_colorStrengthInfo;
	UIView   *_colorHueInfo;
	UILabel  *_colorSaturationInfo;
	UILabel  *_colorGrainInfo;
	
	/* Dimensions */
	CGRect _lineSettingButtonFrame[2];
	CGRect _fieldSettingButtonFrame[2];
	CGRect _colorSettingButtonFrame[2];
}

SINGLETON_INTR(MainViewController);

- (void) updateClipboardButtonColor;
- (void) showModalMessage:(NSString*)message;

- (void) setPurchasePrice:(NSString*)price;

- (void) restoreDefaultSliders;

@end
