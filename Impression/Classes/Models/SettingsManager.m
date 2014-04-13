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
		_lineWidth = [_defaults objectForKey:@"lineWidth"] ? [_defaults floatForKey:@"lineWidth"] : 0.05;
		_lineCount = [_defaults objectForKey:@"lineCount"] ? [_defaults floatForKey:@"lineCount"] : 0.05;
		_lineAlpha = [_defaults objectForKey:@"lineAlpha"] ? [_defaults floatForKey:@"lineAlpha"] : 0.85;
		_lineSpeed = [_defaults objectForKey:@"lineSpeed"] ? [_defaults floatForKey:@"lineSpeed"] : 0.35;
		
		_tintStrength = [_defaults objectForKey:@"tintStrength"] ? [_defaults floatForKey:@"tintStrength"] : 0;
		_tintHue      = [_defaults objectForKey:@"tintHue"]      ? [_defaults floatForKey:@"tintHue"]      : 0;
	}
	return self;
}

- (void) setLineCount:(float)lineCount {
	_lineCount = lineCount;
	FIX_RANGE(_lineCount);
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineCountChangedTo:_lineCount actual:[self actualLineCount]];
}

- (void) setLineWidth:(float)lineWidth {
	_lineWidth = lineWidth;
	FIX_RANGE(_lineWidth);
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineWidthChangedTo:_lineWidth actual:[self actualLineWidth]];
}

- (void) setLineSpeed:(float)lineSpeed {
	_lineSpeed = lineSpeed;
	FIX_RANGE(_lineSpeed);
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineSpeedChangedTo:_lineSpeed actual:[self actualLineSpeed]];
}

- (void) setLineAlpha:(float)lineAlpha {
	_lineAlpha = lineAlpha;
	FIX_RANGE(_lineAlpha);
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingLineAlphaChangedTo:_lineAlpha actual:[self actualLineAlpha]];
}

- (void) setTintHue:(float)tintHue {
	_tintHue = tintHue;
	FIX_RANGE(_tintHue);
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingTintHueChangedTo:_tintHue actual:_tintHue];
}

- (void) setTintStrength:(float)tintStrength {
	_tintStrength = tintStrength;
	FIX_RANGE(_tintStrength);
	for (id<SettingsManagerDelegate> delegate in _delegates) [delegate settingTintStrengthChangedTo:_tintStrength actual:_tintStrength];
}



- (void) updateDelegates {
	for (id<SettingsManagerDelegate> delegate in _delegates) {
		[delegate settingLineCountChangedTo:_lineCount actual:[self actualLineCount]];
		[delegate settingLineWidthChangedTo:_lineWidth actual:[self actualLineWidth]];
		[delegate settingLineAlphaChangedTo:_lineAlpha actual:[self actualLineAlpha]];
		[delegate settingLineSpeedChangedTo:_lineSpeed actual:[self actualLineSpeed]];

		[delegate settingTintStrengthChangedTo:_tintStrength actual:_tintStrength];
		[delegate settingTintHueChangedTo:_tintHue actual:_tintHue];
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
	return (int)(LINE_COUNT_MIN + (LINE_COUNT_MAX - LINE_COUNT_MIN) * _lineCount);
}

- (float) actualLineWidth {
	#define LINE_WIDTH_MIN 2.0
	#define LINE_WIDTH_MAX 40.0
	return (LINE_WIDTH_MIN + (LINE_WIDTH_MAX - LINE_WIDTH_MIN) * _lineWidth);
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


@end
