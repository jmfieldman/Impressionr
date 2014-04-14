//
//  MainViewController.m
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

/* Screen Gestures

 one   finger pan    vertical         - line speed
 one   finger pan    horizontal       - line width
 
 two   finger pan    vertical         - line count
 two   finger pan    horizontal       - line alpha
 
 three finger pan    vertical         - angle field scale
 three finger pan    horizontal       - angle field weight
 
 two   finger pinch                   - tint strength
 two   finger rotate                  - tint hue
 
 four  finger pan    vertical         - grain opacity
 four  finger pan    horizontal       - saturation
 
*/

#define GESTURES_ENABLED 0

@implementation MainViewController

SINGLETON_IMPL(MainViewController);

- (id)init {
	if ((self = [super init])) {
		
		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor redColor];
		
		#if GESTURES_ENABLED
		_gesturePad = [[UIView alloc] initWithFrame:self.view.bounds];
		_gesturePad.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_gesturePad];
		#endif
		
		_paintView = [[ImpressionPainterView alloc] initWithFrame:self.view.bounds];
		_paintView.largestImageDimension = 2000;
		_paintView.image = [UIImage imageNamed:@"test_image1.jpg"];
		_paintView.painting = YES;
		_paintView.opaque = YES;
		_paintView.userInteractionEnabled = NO;
		_paintView.fpsDelegate = self;		
		[self.view addSubview:_paintView];
		
		#if GESTURES_ENABLED /* This was just a glorious disaster. */
		/* Register gesture handlers */
		UIDirectionalPanGestureRecognizer *onePanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnePan:)];
		onePanVert.minimumNumberOfTouches = onePanVert.maximumNumberOfTouches = 1;
		[_gesturePad addGestureRecognizer:onePanVert];
		
		UIDirectionalPanGestureRecognizer *twoPanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoPan:)];
		twoPanVert.minimumNumberOfTouches = twoPanVert.maximumNumberOfTouches = 2;
		[_gesturePad addGestureRecognizer:twoPanVert];
		
		UIDirectionalPanGestureRecognizer *threePanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleThreePan:)];
		threePanVert.minimumNumberOfTouches = threePanVert.maximumNumberOfTouches = 3;
		[_gesturePad addGestureRecognizer:threePanVert];
		
		UIDirectionalPanGestureRecognizer *fourPanVert = [[UIDirectionalPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFourPan:)];
		fourPanVert.minimumNumberOfTouches = fourPanVert.maximumNumberOfTouches = 4;
		[_gesturePad addGestureRecognizer:fourPanVert];
		
		UIRotationGestureRecognizer *twoRot = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoRot:)];
		[_gesturePad addGestureRecognizer:twoRot];
		
		UIPinchGestureRecognizer *twoPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoPinch:)];
		[_gesturePad addGestureRecognizer:twoPinch];
		#endif
				
		/* ----- UI Layout ------ */
				
		/* Cancel Button */
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = self.view.bounds;
		[_cancelButton addTarget:self action:@selector(pressedBackgroundCancel:) forControlEvents:UIControlEventTouchDown];
		[self.view addSubview:_cancelButton];
		
		float cornerRadius = 8;
		float settingButtonBGAlpha = 0.75;
		float settingButtonBGWhite = 0.1;
		
		/* FPS Display */
		_fpsLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 100, 5, 100, 48)];
		_fpsLabelContainer.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_fpsLabelContainer.layer.cornerRadius = cornerRadius;
		[self.view addSubview:_fpsLabelContainer];
		
		_fpsLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 17, _fpsLabelContainer.bounds.size.width - 10, _fpsLabelContainer.bounds.size.height - 10)];
		_fpsLabel.backgroundColor = [UIColor clearColor];
		_fpsLabel.textColor = [UIColor whiteColor];
		_fpsLabel.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:12];
		_fpsLabel.textAlignment = NSTextAlignmentCenter;
		[_fpsLabelContainer addSubview:_fpsLabel];
		
		UILabel *apptitle = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, _fpsLabelContainer.bounds.size.width - 10, 16)];
		apptitle.backgroundColor = [UIColor clearColor];
		apptitle.textColor = [UIColor whiteColor];
		apptitle.font = [UIFont fontWithName:@"MuseoSansRounded-700" size:12];
		apptitle.text = @"IMPRESSION";
		apptitle.textAlignment = NSTextAlignmentCenter;
		[_fpsLabelContainer addSubview:apptitle];
		
		UILabel *appauthor = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, _fpsLabelContainer.bounds.size.width - 10, 16)];
		appauthor.backgroundColor = [UIColor clearColor];
		appauthor.textColor = [UIColor whiteColor];
		appauthor.font = [UIFont fontWithName:@"MuseoSansRounded-300" size:7.25];
		appauthor.text = @"BY JASON FIELDMAN";
		appauthor.textAlignment = NSTextAlignmentCenter;
		[_fpsLabelContainer addSubview:appauthor];
		
		/* Create settings buttons */

		_lineSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lineSettingsButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_lineSettingsButton.layer.cornerRadius = cornerRadius;
		[_lineSettingsButton setImage:[UIImage imageNamed:@"line_icon"] forState:UIControlStateNormal];
		[_lineSettingsButton addTarget:self action:@selector(pressedLineSettingsButton:) forControlEvents:UIControlEventTouchDown];
		_lineSettingsButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_lineSettingsButton];
		
		_fieldSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_fieldSettingsButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_fieldSettingsButton.layer.cornerRadius = cornerRadius;
		[_fieldSettingsButton setImage:[UIImage imageNamed:@"wave_icon"] forState:UIControlStateNormal];
		[_fieldSettingsButton addTarget:self action:@selector(pressedFieldSettingsButton:) forControlEvents:UIControlEventTouchDown];
		_fieldSettingsButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_fieldSettingsButton];
		
		_colorSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_colorSettingsButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_colorSettingsButton.layer.cornerRadius = cornerRadius;
		[_colorSettingsButton setImage:[UIImage imageNamed:@"color_icon"] forState:UIControlStateNormal];
		[_colorSettingsButton addTarget:self action:@selector(pressedColorSettingsButton:) forControlEvents:UIControlEventTouchDown];
		_colorSettingsButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_colorSettingsButton];
		
		_playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_playPauseButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_playPauseButton.layer.cornerRadius = cornerRadius;
		[_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
		[_playPauseButton addTarget:self action:@selector(pressedPlayPauseButton:) forControlEvents:UIControlEventTouchDown];
		_playPauseButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_playPauseButton];
		
		_originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_originalButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_originalButton.layer.cornerRadius = cornerRadius;
		[_originalButton setImage:[UIImage imageNamed:@"original"] forState:UIControlStateNormal];
		[_originalButton addTarget:self action:@selector(pressedOriginalButton:) forControlEvents:UIControlEventTouchDown];
		[_originalButton addTarget:self action:@selector(releasedOriginalButton:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside|UIControlEventTouchCancel];
		_originalButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_originalButton];
		
		_loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_loadButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_loadButton.layer.cornerRadius = cornerRadius;
		[_loadButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
		[_loadButton addTarget:self action:@selector(pressedLoadMenuButton:) forControlEvents:UIControlEventTouchDown];
		_loadButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_loadButton];
		
		_saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_saveButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_saveButton.layer.cornerRadius = cornerRadius;
		[_saveButton setImage:[UIImage imageNamed:@"save"] forState:UIControlStateNormal];
		[_saveButton addTarget:self action:@selector(pressedSaveMenuButton:) forControlEvents:UIControlEventTouchDown];
		_saveButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_saveButton];
		
		/* Menus */
		float menuWidth = 200;
		float universalPadding = 8;
		
		_lineSettingsMenu = [[UIView alloc] initWithFrame:self.view.bounds];
		_lineSettingsMenu.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_lineSettingsMenu.layer.cornerRadius = cornerRadius;
		_lineSettingsMenu.alpha = 0;
		[self.view addSubview:_lineSettingsMenu];
		
		_fieldSettingsMenu = [[UIView alloc] initWithFrame:self.view.bounds];
		_fieldSettingsMenu.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_fieldSettingsMenu.layer.cornerRadius = cornerRadius;
		_fieldSettingsMenu.alpha = 0;
		[self.view addSubview:_fieldSettingsMenu];
		
		_colorSettingsMenu = [[UIView alloc] initWithFrame:self.view.bounds];
		_colorSettingsMenu.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_colorSettingsMenu.layer.cornerRadius = cornerRadius;
		_colorSettingsMenu.alpha = 0;
		[self.view addSubview:_colorSettingsMenu];
		
		_loadMenu = [[UIView alloc] initWithFrame:self.view.bounds];
		_loadMenu.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_loadMenu.layer.cornerRadius = cornerRadius;
		_loadMenu.alpha = 0;
		[self.view addSubview:_loadMenu];

		_saveMenu = [[UIView alloc] initWithFrame:self.view.bounds];
		_saveMenu.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_saveMenu.layer.cornerRadius = cornerRadius;
		_saveMenu.alpha = 0;
		[self.view addSubview:_saveMenu];
		
		/* Sliders */
		float labelH = 24;
		float labelY = universalPadding;
		
		float sliderX = universalPadding;
		float sliderY = labelH + universalPadding - 5;
		float sliderW = menuWidth - universalPadding*2;
		float sliderH = 40;
		float sliderYOffset = 60;

		UIColor *labelColor = [UIColor whiteColor];
		UIFont *infoFont = [UIFont fontWithName:@"MuseoSansRounded-700" size:18];
		
		/* -- Line Settings -- */
		
		int menuIndex = 0;
						
		_lineCountInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_lineCountInfo.backgroundColor = [UIColor clearColor];
		_lineCountInfo.textColor = labelColor;
		_lineCountInfo.textAlignment = NSTextAlignmentRight;
		_lineCountInfo.font = infoFont;
		[_lineSettingsMenu addSubview:_lineCountInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Line Count";
			[_lineSettingsMenu addSubview:settingLabel];
		}
		
		_lineCountSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_lineCountSlider.continuous = YES;
		[_lineCountSlider addTarget:self action:@selector(sliderLineCount:) forControlEvents:UIControlEventValueChanged];
		[_lineCountSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_lineCountSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_lineCountSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_lineSettingsMenu addSubview:_lineCountSlider];
		
		menuIndex++;
		
		_lineWidthInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_lineWidthInfo.backgroundColor = [UIColor clearColor];
		_lineWidthInfo.textColor = labelColor;
		_lineWidthInfo.textAlignment = NSTextAlignmentRight;
		_lineWidthInfo.font = infoFont;
		[_lineSettingsMenu addSubview:_lineWidthInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Line Width";
			[_lineSettingsMenu addSubview:settingLabel];
		}
		
		_lineWidthSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_lineWidthSlider.continuous = YES;
		[_lineWidthSlider addTarget:self action:@selector(sliderLineWidth:) forControlEvents:UIControlEventValueChanged];
		[_lineWidthSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_lineWidthSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_lineWidthSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_lineSettingsMenu addSubview:_lineWidthSlider];
		
		menuIndex++;
		
		_lineSpeedInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_lineSpeedInfo.backgroundColor = [UIColor clearColor];
		_lineSpeedInfo.textColor = labelColor;
		_lineSpeedInfo.textAlignment = NSTextAlignmentRight;
		_lineSpeedInfo.font = infoFont;
		[_lineSettingsMenu addSubview:_lineSpeedInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Line Speed";
			[_lineSettingsMenu addSubview:settingLabel];
		}
		
		_lineSpeedSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_lineSpeedSlider.continuous = YES;
		[_lineSpeedSlider addTarget:self action:@selector(sliderLineSpeed:) forControlEvents:UIControlEventValueChanged];
		[_lineSpeedSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_lineSpeedSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_lineSpeedSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_lineSettingsMenu addSubview:_lineSpeedSlider];
		
		menuIndex++;
		
		_lineAlphaInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_lineAlphaInfo.backgroundColor = [UIColor clearColor];
		_lineAlphaInfo.textColor = labelColor;
		_lineAlphaInfo.textAlignment = NSTextAlignmentRight;
		_lineAlphaInfo.font = infoFont;
		[_lineSettingsMenu addSubview:_lineAlphaInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Line Alpha";
			[_lineSettingsMenu addSubview:settingLabel];
		}
		
		_lineAlphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_lineAlphaSlider.continuous = YES;
		[_lineAlphaSlider addTarget:self action:@selector(sliderLineAlpha:) forControlEvents:UIControlEventValueChanged];
		[_lineAlphaSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_lineAlphaSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_lineAlphaSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_lineSettingsMenu addSubview:_lineAlphaSlider];
		
		menuIndex++;
		
		/* -- Field Settings -- */

		menuIndex = 0;
		
		_fieldWeightInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_fieldWeightInfo.backgroundColor = [UIColor clearColor];
		_fieldWeightInfo.textColor = labelColor;
		_fieldWeightInfo.textAlignment = NSTextAlignmentRight;
		_fieldWeightInfo.font = infoFont;
		[_fieldSettingsMenu addSubview:_fieldWeightInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Swirl Weight";
			[_fieldSettingsMenu addSubview:settingLabel];
		}
		
		_fieldWeightSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_fieldWeightSlider.continuous = YES;
		[_fieldWeightSlider addTarget:self action:@selector(sliderAngleWeight:) forControlEvents:UIControlEventValueChanged];
		[_fieldWeightSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_fieldWeightSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_fieldWeightSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_fieldSettingsMenu addSubview:_fieldWeightSlider];

		menuIndex++;
		
		_fieldOffsetInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_fieldOffsetInfo.backgroundColor = [UIColor clearColor];
		_fieldOffsetInfo.textColor = labelColor;
		_fieldOffsetInfo.textAlignment = NSTextAlignmentRight;
		_fieldOffsetInfo.font = infoFont;
		[_fieldSettingsMenu addSubview:_fieldOffsetInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Angle Offset";
			[_fieldSettingsMenu addSubview:settingLabel];
		}
		
		_fieldOffsetSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_fieldOffsetSlider.continuous = YES;
		[_fieldOffsetSlider addTarget:self action:@selector(sliderAngleOffset:) forControlEvents:UIControlEventValueChanged];
		[_fieldOffsetSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_fieldOffsetSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_fieldOffsetSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_fieldSettingsMenu addSubview:_fieldOffsetSlider];
		
		menuIndex++;
		
		_fieldScaleInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_fieldScaleInfo.backgroundColor = [UIColor clearColor];
		_fieldScaleInfo.textColor = labelColor;
		_fieldScaleInfo.textAlignment = NSTextAlignmentRight;
		_fieldScaleInfo.font = infoFont;
		[_fieldSettingsMenu addSubview:_fieldScaleInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Swirl Scale";
			[_fieldSettingsMenu addSubview:settingLabel];
		}
		
		_fieldScaleSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_fieldScaleSlider.continuous = YES;
		[_fieldScaleSlider addTarget:self action:@selector(sliderAngleScale:) forControlEvents:UIControlEventValueChanged];
		[_fieldScaleSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_fieldScaleSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_fieldScaleSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_fieldSettingsMenu addSubview:_fieldScaleSlider];
		
		menuIndex++;
		
		_fieldResetButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_fieldResetButton.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_fieldResetButton.backgroundColor = [UIColor whiteColor];
		_fieldResetButton.layer.cornerRadius = sliderH / 2;
		[_fieldResetButton setTitle:@"Reset Swirl Pattern" forState:UIControlStateNormal];
		_fieldResetButton.titleLabel.font = infoFont;
		[_fieldResetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_fieldResetButton addTarget:self action:@selector(pressedSwirlReset:) forControlEvents:UIControlEventTouchDown];
		[_fieldSettingsMenu addSubview:_fieldResetButton];
				
		/* -- Color Settings -- */
		
		menuIndex = 0;
		
		_colorHueInfo = [[UIView alloc] initWithFrame:CGRectMake(menuWidth - 70, labelY + (sliderYOffset * menuIndex) + 2, 60, labelH - 4)];
		//_colorHueInfo = [[UIView alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_colorHueInfo.layer.borderWidth = 4;
		_colorHueInfo.layer.borderColor = [UIColor whiteColor].CGColor;
		_colorHueInfo.layer.cornerRadius = _colorHueInfo.frame.size.height / 2;
		_colorHueInfo.backgroundColor = [UIColor clearColor];
		[_colorSettingsMenu addSubview:_colorHueInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Tint Hue";
			[_colorSettingsMenu addSubview:settingLabel];
		}
		
		_colorHueSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_colorHueSlider.continuous = YES;
		[_colorHueSlider addTarget:self action:@selector(sliderTintHue:) forControlEvents:UIControlEventValueChanged];
		[_colorHueSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_colorHueSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_colorHueSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_colorSettingsMenu addSubview:_colorHueSlider];
		
		menuIndex++;
		
		_colorStrengthInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_colorStrengthInfo.backgroundColor = [UIColor clearColor];
		_colorStrengthInfo.textColor = labelColor;
		_colorStrengthInfo.textAlignment = NSTextAlignmentRight;
		_colorStrengthInfo.font = infoFont;
		[_colorSettingsMenu addSubview:_colorStrengthInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Tint Strength";
			[_colorSettingsMenu addSubview:settingLabel];
		}
		
		_colorStrengthSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_colorStrengthSlider.continuous = YES;
		[_colorStrengthSlider addTarget:self action:@selector(sliderTintStrength:) forControlEvents:UIControlEventValueChanged];
		[_colorStrengthSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_colorStrengthSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_colorStrengthSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_colorSettingsMenu addSubview:_colorStrengthSlider];
		
		menuIndex++;
		
		_colorSaturationInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_colorSaturationInfo.backgroundColor = [UIColor clearColor];
		_colorSaturationInfo.textColor = labelColor;
		_colorSaturationInfo.textAlignment = NSTextAlignmentRight;
		_colorSaturationInfo.font = infoFont;
		[_colorSettingsMenu addSubview:_colorSaturationInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Saturation";
			[_colorSettingsMenu addSubview:settingLabel];
		}
		
		_colorSaturationSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_colorSaturationSlider.continuous = YES;
		[_colorSaturationSlider addTarget:self action:@selector(sliderSaturation:) forControlEvents:UIControlEventValueChanged];
		[_colorSaturationSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_colorSaturationSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_colorSaturationSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_colorSettingsMenu addSubview:_colorSaturationSlider];
		
		menuIndex++;
		
		_colorGrainInfo = [[UILabel alloc] initWithFrame:CGRectMake(sliderX, labelY + (sliderYOffset * menuIndex), sliderW - 5, labelH)];
		_colorGrainInfo.backgroundColor = [UIColor clearColor];
		_colorGrainInfo.textColor = labelColor;
		_colorGrainInfo.textAlignment = NSTextAlignmentRight;
		_colorGrainInfo.font = infoFont;
		[_colorSettingsMenu addSubview:_colorGrainInfo];
		
		{
			UILabel *settingLabel = [[UILabel alloc] initWithFrame:CGRectMake(universalPadding + 5, labelY + (sliderYOffset * menuIndex), sliderW, labelH)];
			settingLabel.backgroundColor = [UIColor clearColor];
			settingLabel.textColor = labelColor;
			settingLabel.textAlignment = NSTextAlignmentLeft;
			settingLabel.font = infoFont;
			settingLabel.text = @"Grain Opacity";
			[_colorSettingsMenu addSubview:settingLabel];
		}
		
		_colorGrainSlider = [[UISlider alloc] initWithFrame:CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex), sliderW, sliderH)];
		_colorGrainSlider.continuous = YES;
		[_colorGrainSlider addTarget:self action:@selector(sliderGrainOpacity:) forControlEvents:UIControlEventValueChanged];
		[_colorGrainSlider setMinimumTrackImage:[[UIImage imageNamed:@"slider_track_min"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 0)] forState:UIControlStateNormal];
		[_colorGrainSlider setMaximumTrackImage:[[UIImage imageNamed:@"slider_track_max"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 9)] forState:UIControlStateNormal];
		[_colorGrainSlider setThumbImage:[UIImage imageNamed:@"slider_thumb"] forState:UIControlStateNormal];
		[_colorSettingsMenu addSubview:_colorGrainSlider];
		
		menuIndex++;

		/* -- Load Settings -- */
		
		sliderY = 44;
		sliderYOffset = sliderH + universalPadding + 3;
		menuIndex = 0;
		
		UILabel *loadTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 40)];
		loadTitle.backgroundColor = [UIColor clearColor];
		loadTitle.textColor = [UIColor whiteColor];
		loadTitle.text = @"Load From";
		loadTitle.font = infoFont;
		loadTitle.textAlignment = NSTextAlignmentCenter;
		[_loadMenu addSubview:loadTitle];
		_loadMenuHeight = sliderY;
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
			_loadFromAlbum = [UIButton buttonWithType:UIButtonTypeCustom];
			_loadFromAlbum.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
			_loadFromAlbum.backgroundColor = [UIColor whiteColor];
			_loadFromAlbum.layer.cornerRadius = sliderH / 2;
			[_loadFromAlbum setTitle:@"Photo Album" forState:UIControlStateNormal];
			_loadFromAlbum.titleLabel.font = infoFont;
			[_loadFromAlbum setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[_loadFromAlbum addTarget:self action:@selector(pressedLoadButton:) forControlEvents:UIControlEventTouchDown];
			[_loadMenu addSubview:_loadFromAlbum];
			_loadMenuHeight += sliderYOffset;
			
			menuIndex++;
		}
		
		if (0 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
			_loadFromRoll = [UIButton buttonWithType:UIButtonTypeCustom];
			_loadFromRoll.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
			_loadFromRoll.backgroundColor = [UIColor whiteColor];
			_loadFromRoll.layer.cornerRadius = sliderH / 2;
			[_loadFromRoll setTitle:@"Camera Roll" forState:UIControlStateNormal];
			_loadFromRoll.titleLabel.font = infoFont;
			[_loadFromRoll setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[_loadFromRoll addTarget:self action:@selector(pressedLoadButton:) forControlEvents:UIControlEventTouchDown];
			[_loadMenu addSubview:_loadFromRoll];
			_loadMenuHeight += sliderYOffset;
			
			menuIndex++;
		}
		
		_loadFromClip = [UIButton buttonWithType:UIButtonTypeCustom];
		_loadFromClip.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_loadFromClip.backgroundColor = [UIColor whiteColor];
		_loadFromClip.layer.cornerRadius = sliderH / 2;
		[_loadFromClip setTitle:@"Clipboard" forState:UIControlStateNormal];
		_loadFromClip.titleLabel.font = infoFont;
		[_loadFromClip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_loadFromClip addTarget:self action:@selector(pressedLoadButton:) forControlEvents:UIControlEventTouchDown];
		[_loadMenu addSubview:_loadFromClip];
		[self updateClipboardButtonColor];
		_loadMenuHeight += sliderYOffset;
		
		menuIndex++;
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			_loadFromCamera = [UIButton buttonWithType:UIButtonTypeCustom];
			_loadFromCamera.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
			_loadFromCamera.backgroundColor = [UIColor whiteColor];
			_loadFromCamera.layer.cornerRadius = sliderH / 2;
			[_loadFromCamera setTitle:@"Take Camera Photo" forState:UIControlStateNormal];
			_loadFromCamera.titleLabel.font = infoFont;
			[_loadFromCamera setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[_loadFromCamera addTarget:self action:@selector(pressedLoadButton:) forControlEvents:UIControlEventTouchDown];
			[_loadMenu addSubview:_loadFromCamera];
			_loadMenuHeight += sliderYOffset;
			
			menuIndex++;
		}
		
		/* -- Save Settings -- */
		
		sliderY = 44;
		sliderYOffset = sliderH + universalPadding + 3;
		menuIndex = 0;
		
		UILabel *saveTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth, 40)];
		saveTitle.backgroundColor = [UIColor clearColor];
		saveTitle.textColor = [UIColor whiteColor];
		saveTitle.text = @"Save/Post To";
		saveTitle.font = infoFont;
		saveTitle.textAlignment = NSTextAlignmentCenter;
		[_saveMenu addSubview:saveTitle];
		_saveMenuHeight = sliderY;		
		
		_saveToAlbum = [UIButton buttonWithType:UIButtonTypeCustom];
		_saveToAlbum.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_saveToAlbum.backgroundColor = [UIColor whiteColor];
		_saveToAlbum.layer.cornerRadius = sliderH / 2;
		[_saveToAlbum setTitle:@"Photo Album" forState:UIControlStateNormal];
		_saveToAlbum.titleLabel.font = infoFont;
		[_saveToAlbum setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_saveToAlbum addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchDown];
		[_saveMenu addSubview:_saveToAlbum];
		_saveMenuHeight += sliderYOffset;
		
		menuIndex++;
		
		_saveToClip = [UIButton buttonWithType:UIButtonTypeCustom];
		_saveToClip.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_saveToClip.backgroundColor = [UIColor whiteColor];
		_saveToClip.layer.cornerRadius = sliderH / 2;
		[_saveToClip setTitle:@"Clipboard" forState:UIControlStateNormal];
		_saveToClip.titleLabel.font = infoFont;
		[_saveToClip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_saveToClip addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchDown];
		[_saveMenu addSubview:_saveToClip];
		_saveMenuHeight += sliderYOffset;
		
		menuIndex++;
		
		_saveToFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
		_saveToFacebook.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_saveToFacebook.backgroundColor = [UIColor whiteColor];
		_saveToFacebook.layer.cornerRadius = sliderH / 2;
		[_saveToFacebook setTitle:@"Facebook" forState:UIControlStateNormal];
		_saveToFacebook.titleLabel.font = infoFont;
		[_saveToFacebook setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_saveToFacebook addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchDown];
		[_saveMenu addSubview:_saveToFacebook];
		_saveMenuHeight += sliderYOffset;
		
		menuIndex++;
		
		_saveToInstagram = [UIButton buttonWithType:UIButtonTypeCustom];
		_saveToInstagram.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_saveToInstagram.backgroundColor = [UIColor whiteColor];
		_saveToInstagram.layer.cornerRadius = sliderH / 2;
		[_saveToInstagram setTitle:@"Instagram" forState:UIControlStateNormal];
		_saveToInstagram.titleLabel.font = infoFont;
		[_saveToInstagram setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_saveToInstagram addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchDown];
		[_saveMenu addSubview:_saveToInstagram];
		_saveMenuHeight += sliderYOffset;
		
		menuIndex++;
		
		_saveToOther = [UIButton buttonWithType:UIButtonTypeCustom];
		_saveToOther.frame = CGRectMake(sliderX, sliderY + (sliderYOffset * menuIndex) - 5, sliderW, sliderH);
		_saveToOther.backgroundColor = [UIColor whiteColor];
		_saveToOther.layer.cornerRadius = sliderH / 2;
		[_saveToOther setTitle:@"Other" forState:UIControlStateNormal];
		_saveToOther.titleLabel.font = infoFont;
		[_saveToOther setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_saveToOther addTarget:self action:@selector(pressedSaveButton:) forControlEvents:UIControlEventTouchDown];
		[_saveMenu addSubview:_saveToOther];
		_saveMenuHeight += sliderYOffset;
		
		menuIndex++;
		
		
		/* Set frames */
		[self setControlFrames:UIInterfaceOrientationPortrait];
		
		/* Register for settings */
		[[SettingsManager sharedInstance] addDelegate:self];
	}
	return self;
}

/* We don't want a status bar */
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void) updateClipboardButtonColor {
	BOOL photoAvailable = [UIPasteboard generalPasteboard].image != nil;
	[_loadFromClip setTitleColor:(photoAvailable ? [UIColor blackColor] : [UIColor grayColor]) forState:UIControlStateNormal];
	_loadFromClip.userInteractionEnabled = photoAvailable;
}

- (void) setControlFrames:(UIInterfaceOrientation)orientation {
	//BOOL portrait = (orientation == UIInterfaceOrientationPortrait);
	
	float settingButtonSize = 48;
	float universalPadding = 5;
	float settingButtonOffset = settingButtonSize + universalPadding;
	float settingButtonGroupX = self.view.bounds.size.width - settingButtonOffset * 3;
	float settingButtonY = self.view.bounds.size.height - settingButtonOffset;
	
	/* Painting view */
	_paintView.frame = self.view.bounds;
	[_paintView recalculateScaling];
	
	/* FPS */
	_fpsLabelContainer.frame = CGRectMake(self.view.bounds.size.width - _fpsLabelContainer.bounds.size.width - universalPadding, _fpsLabelContainer.frame.origin.y, _fpsLabelContainer.bounds.size.width, _fpsLabelContainer.bounds.size.height);
	
	/* Control buttons */
	_lineSettingsButton.frame  = CGRectMake(settingButtonGroupX, settingButtonY, settingButtonSize, settingButtonSize);
	_fieldSettingsButton.frame = CGRectMake(settingButtonGroupX + settingButtonOffset*1, settingButtonY, settingButtonSize, settingButtonSize);
	_colorSettingsButton.frame = CGRectMake(settingButtonGroupX + settingButtonOffset*2, settingButtonY, settingButtonSize, settingButtonSize);
	
	_playPauseButton.frame = CGRectMake(universalPadding, settingButtonY, settingButtonSize, settingButtonSize);
	_originalButton.frame  = CGRectMake(universalPadding + settingButtonOffset*1, settingButtonY, settingButtonSize, settingButtonSize);
	
	_loadButton.frame = CGRectMake(universalPadding, universalPadding, settingButtonSize, settingButtonSize);
	_saveButton.frame = CGRectMake(universalPadding + settingButtonOffset*1, universalPadding, settingButtonSize, settingButtonSize);
	
	float menuWidth = 200;
	float menuX = self.view.bounds.size.width - menuWidth - universalPadding;
	
	float lineSettingsMenuHeight = 260;
	float lineSettingsMenuY      = self.view.bounds.size.height - universalPadding * 2 - settingButtonSize - lineSettingsMenuHeight;
	
	float fieldSettingsMenuHeight = 260;
	float fieldSettingsMenuY      = self.view.bounds.size.height - universalPadding * 2 - settingButtonSize - fieldSettingsMenuHeight;
	
	float colorSettingsMenuHeight = 260;
	float colorSettingsMenuY      = self.view.bounds.size.height - universalPadding * 2 - settingButtonSize - colorSettingsMenuHeight;
	
	_lineSettingsMenu.frame  = CGRectMake(menuX, lineSettingsMenuY,  menuWidth, lineSettingsMenuHeight);
	_fieldSettingsMenu.frame = CGRectMake(menuX, fieldSettingsMenuY, menuWidth, fieldSettingsMenuHeight);
	_colorSettingsMenu.frame = CGRectMake(menuX, colorSettingsMenuY, menuWidth, colorSettingsMenuHeight);
	
	_loadMenu.frame = CGRectMake(universalPadding, universalPadding + settingButtonOffset, menuWidth, _loadMenuHeight);
	_saveMenu.frame = CGRectMake(universalPadding, universalPadding + settingButtonOffset, menuWidth, _saveMenuHeight);
	
	/* Adjust cancel button */
	_cancelButton.frame = self.view.bounds;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self setControlFrames:interfaceOrientation];
}

- (void) pressedBackgroundCancel:(id)sender {
	[self hideCurrentMenu];
}

- (float) hideCurrentMenu {
	if (!_currentlyDisplayedMenu) return 0;
	
	[_currentlyDisplayedMenu.layer removeAnimationForKey:@"zoom"];
	_currentlyDisplayedMenu.transform = CGAffineTransformIdentity;
	
	UIView *tempCurrentView = _currentlyDisplayedMenu;
	[UIView animateWithDuration:0.25
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 tempCurrentView.transform = CGAffineTransformMakeScale(0.8, 0.8);
						 tempCurrentView.alpha = 0;
					 } completion:^(BOOL finished) { tempCurrentView.transform = CGAffineTransformIdentity; }];

	_currentlyDisplayedMenu = nil;
	
	return 0.075;
}

- (void) popInView:(UIView*)view {
	SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:@"transform"];
	bounceAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)];
	bounceAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	bounceAnimation.duration = 0.4f;
	bounceAnimation.removedOnCompletion = NO;
	bounceAnimation.fillMode = kCAFillModeForwards;
	bounceAnimation.numberOfBounces = 3;
	bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
	bounceAnimation.beginTime = CACurrentMediaTime();
	[view.layer addAnimation:bounceAnimation forKey:@"zoom"];
	
	[UIView animateWithDuration:0.25
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 view.alpha = 1;
					 } completion:nil];

}

- (void) animatePop:(UIView*)view {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	anim.fromValue = @(1);
	anim.toValue = @(1.05);
	anim.duration = 0.075;
	anim.beginTime = CACurrentMediaTime();
	anim.removedOnCompletion = NO;
	anim.fillMode = kCAFillModeForwards;
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	anim.autoreverses = YES;
	[view.layer addAnimation:anim forKey:@"scale"];
}

- (void) pressedSwirlReset:(id)sender {
	[self animatePop:_fieldResetButton];
	[_paintView resetNoiseGrid];
	
}

- (void) pressedLineSettingsButton:(id)sender {
	if (_currentlyDisplayedMenu == _lineSettingsMenu) { [self hideCurrentMenu]; return; }
		
	[self performSelector:@selector(popInView:) withObject:_lineSettingsMenu afterDelay:[self hideCurrentMenu]];
	_currentlyDisplayedMenu = _lineSettingsMenu;
}

- (void) pressedFieldSettingsButton:(id)sender {
	if (_currentlyDisplayedMenu == _fieldSettingsMenu) { [self hideCurrentMenu]; return; }
	
	[self performSelector:@selector(popInView:) withObject:_fieldSettingsMenu afterDelay:[self hideCurrentMenu]];
	_currentlyDisplayedMenu = _fieldSettingsMenu;
}

- (void) pressedColorSettingsButton:(id)sender {
	if (_currentlyDisplayedMenu == _colorSettingsMenu) { [self hideCurrentMenu]; return; }
	
	[self performSelector:@selector(popInView:) withObject:_colorSettingsMenu afterDelay:[self hideCurrentMenu]];
	_currentlyDisplayedMenu = _colorSettingsMenu;
}

- (void) pressedLoadMenuButton:(id)sender {
	if (_currentlyDisplayedMenu == _loadMenu) { [self hideCurrentMenu]; return; }
	
	[self performSelector:@selector(popInView:) withObject:_loadMenu afterDelay:[self hideCurrentMenu]];
	_currentlyDisplayedMenu = _loadMenu;
}

- (void) pressedSaveMenuButton:(id)sender {
	if (_currentlyDisplayedMenu == _saveMenu) { [self hideCurrentMenu]; return; }
	
	[self performSelector:@selector(popInView:) withObject:_saveMenu afterDelay:[self hideCurrentMenu]];
	_currentlyDisplayedMenu = _saveMenu;
}

- (void) pressedPlayPauseButton:(id)sender {
	_paintView.painting = !_paintView.painting;
	
	[_playPauseButton setImage:[UIImage imageNamed:_paintView.painting ? @"pause" : @"play"] forState:UIControlStateNormal];
}

- (void) pressedOriginalButton:(id)sender {
	_paintView.overlayOriginal = YES;
}

- (void) releasedOriginalButton:(id)sender {
	_paintView.overlayOriginal = NO;
}

- (void) pressedLoadButton:(UIButton*)sender {
	[self popInView:sender];
	[self hideCurrentMenu];
	
	if (sender != _loadFromClip) {
		/* Load from picker */
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.allowsEditing = NO;
		if (sender == _loadFromCamera)
			picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		if (sender == _loadFromAlbum)
			picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		if (sender == _loadFromRoll)
			picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		
		picker.delegate = self;
		[self presentViewController:picker animated:YES completion:nil];
		
	} else {
		/* Clipboard */
		UIImage *clipped = [UIPasteboard generalPasteboard].image;
		if (clipped) {
			_paintView.image = [self normalizedImage:clipped];
		}
	}
}

- (void) pressedSaveButton:(UIButton*)sender {
	[self popInView:sender];
	[self hideCurrentMenu];
	
	if (sender == _saveToClip) {
		[UIPasteboard generalPasteboard].image = _paintView.renderedImage;
	} else if (sender == _saveToAlbum) {
		UIImageWriteToSavedPhotosAlbum(_paintView.renderedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	} else if (sender == _saveToFacebook) {
		SLComposeViewController *composer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
		[composer addImage:_paintView.renderedImage];
		[composer setInitialText:@"Created with the Impression iOS app!"];
		[self presentViewController:composer animated:YES completion:nil];
	} else if (sender == _saveToInstagram) {
		/* Create the file */
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *imgFilePath = [paths[0] stringByAppendingPathComponent:@"upload.igo"];
		NSData *imgData = UIImageJPEGRepresentation(_paintView.image, 0.9);
		[imgData writeToFile:imgFilePath atomically:YES];
		
		static __strong UIDocumentInteractionController *documentInteractionController = nil;
		documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imgFilePath]];
		documentInteractionController.UTI = @"com.instagram.exclusivegram";
		//documentInteractionController.annotation = [NSDictionary dictionaryWithObject:@"Created with the Impression iOS app!" forKey:@"InstagramCaption"];
		BOOL response = [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
	} else if (sender == _saveToOther) {
		/* Create the file */
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString *imgFilePath = [paths[0] stringByAppendingPathComponent:@"upload.jpg"];
		NSData *imgData = UIImageJPEGRepresentation(_paintView.image, 0.9);
		[imgData writeToFile:imgFilePath atomically:YES];
		
		static __strong UIDocumentInteractionController *documentInteractionController = nil;
		documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imgFilePath]];
		//documentInteractionController.annotation = [NSDictionary dictionaryWithObject:@"Created with the Impression iOS app!" forKey:@"InstagramCaption"];
		BOOL response = [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
	}
}

- (void) image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo {
	
}

#pragma mark UIImagePickerViewControllerDelegate methods

- (UIImage*) normalizedImage:(UIImage*)ofImage {
	if (ofImage.imageOrientation == UIImageOrientationUp) return ofImage;
	
    UIGraphicsBeginImageContextWithOptions(ofImage.size, NO, ofImage.scale);
    [ofImage drawInRect:(CGRect){0, 0, ofImage.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[self dismissViewControllerAnimated:YES completion:nil];
	
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	if (image) {
		_paintView.image = [self normalizedImage:image];
	}
}

#pragma mark UIGestureRecognizerDelegate methods

- (void) handleOnePan:(UIDirectionalPanGestureRecognizer*)pan {
	CGPoint translation = [pan translationInView:_gesturePad];
	if (pan.direction == PAN_DIR_HORIZONTAL) {
		[SettingsManager sharedInstance].lineWidth += translation.x / (self.view.bounds.size.width/2);
	} else if (pan.direction == PAN_DIR_VERTICAL) {
		[SettingsManager sharedInstance].lineSpeed -= translation.y / (self.view.bounds.size.height/2);
	}
	
	[pan setTranslation:CGPointZero inView:_gesturePad];
}

- (void) handleTwoPan:(UIDirectionalPanGestureRecognizer*)pan {
	CGPoint translation = [pan translationInView:_gesturePad];
	if (pan.direction == PAN_DIR_HORIZONTAL) {
		[SettingsManager sharedInstance].lineAlpha += translation.x / (self.view.bounds.size.width/2);
	} else if (pan.direction == PAN_DIR_VERTICAL) {
		[SettingsManager sharedInstance].lineCount -= translation.y / (self.view.bounds.size.height/2);
	}
	
	[pan setTranslation:CGPointZero inView:_gesturePad];
}

- (void) handleThreePan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleFourPan:(UIDirectionalPanGestureRecognizer*)pan {
	
}

- (void) handleTwoRot:(UIRotationGestureRecognizer*)rot {
	[SettingsManager sharedInstance].tintHue += rot.rotation;
	rot.rotation = 0;
}

- (void) handleTwoPinch:(UIPinchGestureRecognizer*)pinch {
	[SettingsManager sharedInstance].tintStrength += pinch.scale - 1;
	pinch.scale = 1;
}

#pragma mark Slider Touch handlers

- (void) sliderLineWidth:(UISlider*)sender {
	[SettingsManager sharedInstance].lineWidth = sender.value;
}

- (void) sliderLineCount:(UISlider*)sender {
	[SettingsManager sharedInstance].lineCount = sender.value;
}

- (void) sliderLineSpeed:(UISlider*)sender {
	[SettingsManager sharedInstance].lineSpeed = sender.value;
}

- (void) sliderLineAlpha:(UISlider*)sender {
	[SettingsManager sharedInstance].lineAlpha = sender.value;
}

- (void) sliderAngleWeight:(UISlider*)sender {
	[SettingsManager sharedInstance].angleFieldWeight = sender.value;
}

- (void) sliderAngleOffset:(UISlider*)sender {
	[SettingsManager sharedInstance].angleFieldOffset = sender.value;
}

- (void) sliderAngleScale:(UISlider*)sender {
	[SettingsManager sharedInstance].angleFieldScale = sender.value;
}

- (void) sliderTintStrength:(UISlider*)sender {
	[SettingsManager sharedInstance].tintStrength = sender.value;
}

- (void) sliderTintHue:(UISlider*)sender {
	[SettingsManager sharedInstance].tintHue = sender.value;
}

- (void) sliderSaturation:(UISlider*)sender {
	[SettingsManager sharedInstance].saturation = sender.value;
}

- (void) sliderGrainOpacity:(UISlider*)sender {
	[SettingsManager sharedInstance].grainOpacity = sender.value;
}



#pragma mark SettingsManagerDelegate methods


- (void) settingLineWidthChangedTo:(float)slider actual:(float)width {
	_paintView.lineWidth = width;
	_lineWidthSlider.value = slider;
	_lineWidthInfo.text = [NSString stringWithFormat:@"%d", (int)width];
}

- (void) settingLineSpeedChangedTo:(float)slider actual:(float)speed {
	_paintView.lineSpeed = speed;
	_lineSpeedSlider.value = slider;
	_lineSpeedInfo.text = [NSString stringWithFormat:@"%d", (int)(speed)];
}

- (void) settingLineCountChangedTo:(float)slider actual:(int)count {
	_paintView.lineCount = count;
	_lineCountSlider.value = slider;
	_lineCountInfo.text = [NSString stringWithFormat:@"%d", count];
}

- (void) settingLineAlphaChangedTo:(float)slider actual:(float)alpha {
	_paintView.lineAlpha = alpha;
	_lineAlphaSlider.value = slider;
	_lineAlphaInfo.text = [NSString stringWithFormat:@"%d%%", (int)(alpha * 100)];
}

- (void) settingAngleFieldScaleChangedTo:(float)slider actual:(float)scale {
	_paintView.noiseScale = scale;
	_fieldScaleSlider.value = slider;
	_fieldScaleInfo.text = [NSString stringWithFormat:@"%d%%", (int)(scale * 100)];
}

- (void) settingAngleFieldWeightChangedTo:(float)slider actual:(float)weight {
	_paintView.lineAngleFieldWeight = slider;
	_fieldWeightSlider.value = slider;
	_fieldWeightInfo.text = [NSString stringWithFormat:@"%d%%", (int)(weight * 100)];
}

- (void) settingAngleFieldOffsetChangedTo:(float)slider actual:(float)offset {
	_paintView.noiseOffset = slider;
	_fieldOffsetSlider.value = slider;
	_fieldOffsetInfo.text = [NSString stringWithFormat:@"%d°", (int)(slider * 360)];
}

- (void) settingTintStrengthChangedTo:(float)slider actual:(float)strength {
	_paintView.colorTintStrength = strength;
	_colorStrengthSlider.value = slider;
	_colorStrengthInfo.text = [NSString stringWithFormat:@"%d%%", (int)(strength * 100)];
}

- (void) settingTintHueChangedTo:(float)slider actual:(float)hue {
	_paintView.colorHue = hue;
	_colorHueSlider.value = slider;
	_colorHueInfo.backgroundColor = [UIColor colorWithHue:hue saturation:1 brightness:1 alpha:1];
}

- (void) settingSaturationChangedTo:(float)slider actual:(float)saturation {
	_paintView.colorSaturation = saturation;
	_colorSaturationSlider.value = slider;
	_colorSaturationInfo.text = [NSString stringWithFormat:@"%d%%", (int)(saturation * 100)];
}

- (void) settingGrainOpacityChangedTo:(float)slider actual:(float)grain {
	_paintView.colorGrain = grain;
	_colorGrainSlider.value = slider;
	_colorGrainInfo.text = [NSString stringWithFormat:@"%d%%", (int)(slider * 100)];
}

#pragma mark FPSDelegate methods

- (void) newFPS:(int)fps {
	_fpsLabel.text = [NSString stringWithFormat:@"%d FPS", fps];
}


@end
