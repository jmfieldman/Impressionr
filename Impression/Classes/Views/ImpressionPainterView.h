//
//  ImpressionPainterView.h
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintLine.h"

#define NOISE_GRID_SIZE 5

@protocol FPSDelegate <NSObject>
- (void) newFPS:(int)fps;
@end


@interface ImpressionPainterView : UIView {
	CGContextRef  _bitmapContext;
	int8_t       *_bitmapMemory;
	
	/* Original image */
	uint8_t      *_originalMemory;
	NSInteger     _originalW;
	NSInteger     _originalH;
	UIImageView  *_originalImageView;
	
	/* Lines */
	NSMutableArray *_lines;
	
	/* Timing */
	NSTimeInterval _lastUpdateTime;
	BOOL           _isPainting;
	
	/* Perlin noise chart */
	float          _noiseGrid[NOISE_GRID_SIZE][NOISE_GRID_SIZE];
	
	/* Grain on top */
	UIImageView   *_grainView;
	
	/* FPS tracking */
	NSTimeInterval _lastFPSCheck;
	int            _frameCount;
	
	/* Draw down original image first */
	UIImage       *_originalImageToDraw;
	int            _clearCount;
}

/* FPS Delegate */
@property (nonatomic, weak) id<FPSDelegate> fpsDelegate;

/* Max file size */
@property (nonatomic, assign) float largestImageDimension;

/* The image that we are painting onto the view */
@property (nonatomic, strong) UIImage *image;

/* The currently rendered image */
@property (nonatomic, readonly) UIImage *renderedImage;

/* The scale for length properties based on the resolution of the image */
@property (nonatomic, readonly) float imageDrawingScale;

/* The internal frame that the image is painted to based on aspect ratio */
@property (nonatomic, readonly) CGRect imageDrawingRect;

/* turn the active painting process on or off */
@property (nonatomic, assign) BOOL painting;

/* The time between repaints */
@property (nonatomic, assign) float paintingInterval;

/* Show the original overlay? */
@property (nonatomic, assign) BOOL overlayOriginal;

/* --- Noise --- */

/* How much the noise jumps each interval */
@property (nonatomic, readonly) float noiseJitter;

/* What scale to use of the noise grid */
@property (nonatomic, assign) float noiseScale;

/* The noise offset (so waves can rotate) - should be 0-1 */
@property (nonatomic, assign) float noiseOffset;

/* --- Stroke properties --- */

/* The number of lines active in the image */
@property (nonatomic, assign) int lineCount;

/* The desired lifetime of the lines (in seconds) */
@property (nonatomic, assign) float lineLifetime;

/* The width of each line */
@property (nonatomic, assign) float lineWidth;

/* The desired speed of each line (in pixels/sec) */
@property (nonatomic, assign) float lineSpeed;

/* The alpha to use for each line */
@property (nonatomic, assign) float lineAlpha;

/* The angle manipulation for the line field */
@property (nonatomic, assign) float lineAngleFieldWeight;


/* --- Color properties --- */

/* What percent of lines will have the original color vs. generated color */
@property (nonatomic, assign) float colorTintStrength;

/* The HSL values of the artificial color */
@property (nonatomic, assign) float colorHue;
@property (nonatomic, assign) float colorSaturation;
@property (nonatomic, assign) float colorLightness;

/* How much grain to show in the image */
@property (nonatomic, assign) float colorGrain;


- (void) recalculateScaling;
- (void) resetNoiseGrid;
- (void) updatePainting;

@end
