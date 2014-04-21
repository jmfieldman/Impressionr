//
//  SettingsManager.m
//  Impression
//
//  Created by Jason Fieldman on 4/12/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "SettingsManager.h"

#define FIX_RANGE(_var) do { if (_var < 0) _var = 0; else if (_var > 1) _var = 1; } while (0)

@implementation SettingsManager

SINGLETON_IMPL(SettingsManager);

- (id) init {
	if ((self = [super init])) {
		_delegates = [NSMutableArray array];
		
		/* Load defaults */
		_defaults = [NSUserDefaults standardUserDefaults];
		_lineWidth = [_defaults objectForKey:@"lineWidth"] ? [_defaults floatForKey:@"lineWidth"] : 0.15;
		_lineCount = [_defaults objectForKey:@"lineCount"] ? [_defaults floatForKey:@"lineCount"] : 0.70;
		_lineAlpha = [_defaults objectForKey:@"lineAlpha"] ? [_defaults floatForKey:@"lineAlpha"] : 0.85;
		_lineSpeed = [_defaults objectForKey:@"lineSpeed"] ? [_defaults floatForKey:@"lineSpeed"] : 0.25;
		
		_tintStrength = [_defaults objectForKey:@"tintStrength"] ? [_defaults floatForKey:@"tintStrength"] : 0;
		_tintHue      = [_defaults objectForKey:@"tintHue"]      ? [_defaults floatForKey:@"tintHue"]      : 0;
		_grainOpacity = [_defaults objectForKey:@"grainOpactiy"] ? [_defaults floatForKey:@"grainOpactiy"] : 0.5;
		_saturation   = [_defaults objectForKey:@"saturation"]   ? [_defaults floatForKey:@"saturation"]   : 1;
		
		_angleFieldWeight = [_defaults objectForKey:@"fieldWeight"] ? [_defaults floatForKey:@"fieldWeight"] : 1;
		_angleFieldScale  = [_defaults objectForKey:@"fieldScale"]  ? [_defaults floatForKey:@"fieldScale"]  : 1;
		_angleFieldOffset = [_defaults objectForKey:@"fieldOffset"] ? [_defaults floatForKey:@"fieldOffset"] : 0;
		
	}
	return self;
}

- (void) restoreDefaults {
	self.lineWidth = 0.15;
	self.lineAlpha = 0.85;
	self.lineCount = 0.70;
	self.lineSpeed = 0.15;
	
	self.tintStrength = 0;
	self.tintHue      = 0;
	self.grainOpacity = 0.5;
	self.saturation   = 1;
	
	self.angleFieldWeight = 1;
	self.angleFieldOffset = 0;
	self.angleFieldScale  = 1;
}

- (void) setLineCount:(float)lineCount {
	_lineCount = lineCount;
	FIX_RANGE(_lineCount);
	[_defaults setFloat:_lineCount forKey:@"lineCount"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineCountChangedTo:_lineCount actual:[self actualLineCount]];
}

- (void) setLineWidth:(float)lineWidth {
	_lineWidth = lineWidth;
	FIX_RANGE(_lineWidth);
	[_defaults setFloat:_lineWidth forKey:@"lineWidth"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineWidthChangedTo:_lineWidth actual:[self actualLineWidth]];
}

- (void) setLineSpeed:(float)lineSpeed {
	_lineSpeed = lineSpeed;
	FIX_RANGE(_lineSpeed);
	[_defaults setFloat:_lineSpeed forKey:@"lineSpeed"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineSpeedChangedTo:_lineSpeed actual:[self actualLineSpeed]];
}

- (void) setLineAlpha:(float)lineAlpha {
	_lineAlpha = lineAlpha;
	FIX_RANGE(_lineAlpha);
	[_defaults setFloat:_lineAlpha forKey:@"lineAlpha"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineAlphaChangedTo:_lineAlpha actual:[self actualLineAlpha]];
}

- (void) setTintHue:(float)tintHue {
	_tintHue = tintHue;
	FIX_RANGE(_tintHue);
	[_defaults setFloat:_tintHue forKey:@"tintHue"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingTintHueChangedTo:_tintHue actual:_tintHue];
}

- (void) setTintStrength:(float)tintStrength {
	_tintStrength = tintStrength;
	FIX_RANGE(_tintStrength);
	[_defaults setFloat:_tintStrength forKey:@"tintStrength"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingTintStrengthChangedTo:_tintStrength actual:_tintStrength];
}

- (void) setGrainOpacity:(float)grainOpacity {
	_grainOpacity = grainOpacity;
	FIX_RANGE(_grainOpacity);
	[_defaults setFloat:_grainOpacity forKey:@"grainOpactiy"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingGrainOpacityChangedTo:_grainOpacity actual:_grainOpacity];
}

- (void) setSaturation:(float)saturation {
	_saturation = saturation;
	FIX_RANGE(_saturation);
	[_defaults setFloat:_saturation forKey:@"saturation"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingSaturationChangedTo:_saturation actual:_saturation];
}

- (void) setAngleFieldOffset:(float)angleFieldOffset {
	_angleFieldOffset = angleFieldOffset;
	FIX_RANGE(_angleFieldOffset);
	[_defaults setFloat:_angleFieldOffset forKey:@"fieldOffset"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingAngleFieldOffsetChangedTo:_angleFieldOffset actual:[self actualAngleFieldOffset]];
}

- (void) setAngleFieldWeight:(float)angleFieldWeight {
	_angleFieldWeight = angleFieldWeight;
	FIX_RANGE(_angleFieldWeight);
	[_defaults setFloat:_angleFieldWeight forKey:@"fieldWeight"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingAngleFieldWeightChangedTo:_angleFieldWeight actual:_angleFieldWeight];
}

- (void) setAngleFieldScale:(float)angleFieldScale {
	_angleFieldScale = angleFieldScale;
	FIX_RANGE(_angleFieldScale);
	[_defaults setFloat:_angleFieldScale forKey:@"fieldScale"];
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingAngleFieldScaleChangedTo:_angleFieldScale actual:_angleFieldScale];
}



- (void) updateDelegates {
	for (id<SettingsManagerDelegate> delegate in _delegates) {
		[delegate settingLineCountChangedTo:_lineCount actual:[self actualLineCount]];
		[delegate settingLineWidthChangedTo:_lineWidth actual:[self actualLineWidth]];
		[delegate settingLineAlphaChangedTo:_lineAlpha actual:[self actualLineAlpha]];
		[delegate settingLineSpeedChangedTo:_lineSpeed actual:[self actualLineSpeed]];

		[delegate settingAngleFieldOffsetChangedTo:_angleFieldOffset actual:[self actualAngleFieldOffset]];
		[delegate settingAngleFieldScaleChangedTo:_angleFieldScale   actual:_angleFieldScale];
		[delegate settingAngleFieldWeightChangedTo:_angleFieldWeight actual:_angleFieldWeight];
		
		[delegate settingTintStrengthChangedTo:_tintStrength actual:_tintStrength];
		[delegate settingTintHueChangedTo:_tintHue actual:_tintHue];
		[delegate settingGrainOpacityChangedTo:_grainOpacity actual:_grainOpacity];
		[delegate settingSaturationChangedTo:_saturation actual:_saturation];
	}
}

- (void) addDelegate:(id<SettingsManagerDelegate>)delegate {
	[_delegates addObject:delegate];
	[self updateDelegates];
}

- (void) removeDelegate:(id<SettingsManagerDelegate>)delegate {
	[_delegates removeObject:delegate];
}


- (int) actualLineCount {
	#define LINE_COUNT_MIN 10
	#define LINE_COUNT_MAX 200
	return (int)(LINE_COUNT_MIN + (LINE_COUNT_MAX - LINE_COUNT_MIN) * powf(_lineCount, 1.3));
}

- (float) actualLineWidth {
	#define LINE_WIDTH_MIN 1.0
	#define LINE_WIDTH_MAX 40.0
	return (LINE_WIDTH_MIN + (LINE_WIDTH_MAX - LINE_WIDTH_MIN) * powf(_lineWidth, 1.6));
}

- (float) actualLineAlpha {
	#define LINE_ALPHA_MIN 0.05
	#define LINE_ALPHA_MAX 1.0
	if (_lineAlpha == 1) return 1;
	return (LINE_ALPHA_MIN + (LINE_ALPHA_MAX - LINE_ALPHA_MIN) * _lineAlpha);
}

- (float) actualLineSpeed {
	#define LINE_SPEED_MIN 20.0
	#define LINE_SPEED_MAX 500.0
	return (LINE_SPEED_MIN + (LINE_SPEED_MAX - LINE_SPEED_MIN) * _lineSpeed);
}

- (float) actualAngleFieldOffset {
	return _angleFieldOffset * 2 * M_PI;
}

@end
