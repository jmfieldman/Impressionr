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
		_paintView.image = [UIImage imageNamed:@"test_image1.jpg"];
		_paintView.painting = YES;
		_paintView.opaque = YES;
		_paintView.userInteractionEnabled = NO;
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
		
		float cornerRadius = 8;
		float settingButtonBGAlpha = 0.75;
		float settingButtonBGWhite = 0.1;
				
		/* Create settings buttons */

		_lineSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_lineSettingsButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_lineSettingsButton.layer.cornerRadius = cornerRadius;
		[_lineSettingsButton setImage:[UIImage imageNamed:@"line_icon"] forState:UIControlStateNormal];
		_lineSettingsButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_lineSettingsButton];
		
		_fieldSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_fieldSettingsButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_fieldSettingsButton.layer.cornerRadius = cornerRadius;
		[_fieldSettingsButton setImage:[UIImage imageNamed:@"wave_icon"] forState:UIControlStateNormal];
		_fieldSettingsButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_fieldSettingsButton];
		
		_colorSettingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_colorSettingsButton.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_colorSettingsButton.layer.cornerRadius = cornerRadius;
		[_colorSettingsButton setImage:[UIImage imageNamed:@"color_icon"] forState:UIControlStateNormal];
		_colorSettingsButton.imageView.layer.cornerRadius = 3;
		[self.view addSubview:_colorSettingsButton];
		
		/* Menus */
		float menuWidth = 200;
		float universalPadding = 8;
		
		_lineSettingsMenu = [[UIView alloc] initWithFrame:self.view.bounds];
		_lineSettingsMenu.backgroundColor = [UIColor colorWithWhite:settingButtonBGWhite alpha:settingButtonBGAlpha];
		_lineSettingsMenu.layer.cornerRadius = cornerRadius;
		[self.view addSubview:_lineSettingsMenu];
		
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

		
		/* Set frames */
		[self setControlFrames:UIInterfaceOrientationPortrait];
		
		/* Register for settings */
		[[SettingsManager sharedInstance] addDelegate:self];
	}
	return self;
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
	
	/* Control buttons */
	_lineSettingsButton.frame = CGRectMake(settingButtonGroupX, settingButtonY, settingButtonSize, settingButtonSize);
	_fieldSettingsButton.frame = CGRectMake(settingButtonGroupX + settingButtonOffset*1, settingButtonY, settingButtonSize, settingButtonSize);
	_colorSettingsButton.frame = CGRectMake(settingButtonGroupX + settingButtonOffset*2, settingButtonY, settingButtonSize, settingButtonSize);
	
	
	float menuWidth = 200;
	float menuX = self.view.bounds.size.width - menuWidth - universalPadding;
	
	float lineSettingsMenuHeight = 260;
	float lineSettingsMenuY      = self.view.bounds.size.height - universalPadding * 2 - settingButtonSize - lineSettingsMenuHeight;
	
	_lineSettingsMenu.frame = CGRectMake(menuX, lineSettingsMenuY, menuWidth, lineSettingsMenuHeight);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self setControlFrames:interfaceOrientation];
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
}

- (void) settingAngleFieldWeightChangedTo:(float)slider actual:(float)weight {
	_paintView.lineAngleFieldWeight = weight;
}

- (void) settingTintStrengthChangedTo:(float)slider actual:(float)strength {
	_paintView.colorTintStrength = strength;
}

- (void) settingTintHueChangedTo:(float)slider actual:(float)hue {
	_paintView.colorHue = hue;
}

- (void) settingSaturationChangedTo:(float)slider actual:(float)saturation {
	_paintView.colorSaturation = saturation;
}

- (void) settingGrainOpacityChangedTo:(float)slider actual:(float)grain {
	_paintView.colorGrain = grain;
}


@end
