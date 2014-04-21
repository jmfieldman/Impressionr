//
//  SettingsManager.h
//  Impression
//
//  Created by Jason Fieldman on 4/12/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SettingsManagerDelegate <NSObject>
- (void) settingLineWidthChangedTo:(float)slider actual:(float)width;
- (void) settingLineSpeedChangedTo:(float)slider actual:(float)speed;
- (void) settingLineCountChangedTo:(float)slider actual:(int)count;
- (void) settingLineAlphaChangedTo:(float)slider actual:(float)alpha;

- (void) settingAngleFieldScaleChangedTo:(float)slider actual:(float)scale;
- (void) settingAngleFieldWeightChangedTo:(float)slider actual:(float)weight;
- (void) settingAngleFieldOffsetChangedTo:(float)slider actual:(float)offset;

- (void) settingTintStrengthChangedTo:(float)slider actual:(float)strength;
- (void) settingTintHueChangedTo:(float)slider actual:(float)hue;

- (void) settingSaturationChangedTo:(float)slider actual:(float)saturation;
- (void) settingGrainOpacityChangedTo:(float)slider actual:(float)grain;
@end

@interface SettingsManager : NSObject {
	NSMutableArray *_delegates;
	NSUserDefaults *_defaults;
}


@property (nonatomic, assign) float lineWidth;
@property (nonatomic, assign) float lineSpeed;
@property (nonatomic, assign) float lineCount;
@property (nonatomic, assign) float lineAlpha;
@property (nonatomic, assign) float angleFieldScale;
@property (nonatomic, assign) float angleFieldWeight;
@property (nonatomic, assign) float angleFieldOffset;
@property (nonatomic, assign) float tintStrength;
@property (nonatomic, assign) float tintHue;
@property (nonatomic, assign) float grainOpacity;
@property (nonatomic, assign) float saturation;

SINGLETON_INTR(SettingsManager);

- (void) addDelegate:(id<SettingsManagerDelegate>)delegate;
- (void) removeDelegate:(id<SettingsManagerDelegate>)delegate;

- (void) restoreDefaults;

@end
