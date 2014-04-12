//
//  ImpressionPainterView.m
//  Impression
//
//  Created by Jason Fieldman on 4/9/14.
//  Copyright (c) 2014 Jason Fieldman. All rights reserved.
//

#import "ImpressionPainterView.h"


@implementation ImpressionPainterView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_paintingInterval = 0.01;
		
		/* Set hardcoded default attributes */
		_lineWidth            = 10;
		_lineCount            = 20;
		_lineLifetime         = 0.1;
		_lineSpeed            = 400;
		_lineAlpha            = 0.2;
		_lineAngleFieldWeight = 1;
		
		_noiseJitter          = 0.5;
		_noiseScale           = 1;
		
		_colorOriginalProb    = 1;
		_colorHue             = 0.8;
		_colorSaturation      = 1;
		_colorLightness       = 1;
		_colorGrain           = 0.15;
		
		_imageDrawingScale    = 1;
		
		/* Fill noise */
		_noiseGrid[0][0]                                 = 0;
		_noiseGrid[NOISE_GRID_SIZE-1][0]                 = 0.25;
		_noiseGrid[0][NOISE_GRID_SIZE-1]                 = 0.75;
		_noiseGrid[NOISE_GRID_SIZE-1][NOISE_GRID_SIZE-1] = 0;
		[self fillNoiseGridFromX1:0 y1:0 x2:NOISE_GRID_SIZE-1 y2:NOISE_GRID_SIZE-1 depth:0];
		
		/* DEBUG */
		#if 1
		NSMutableString *s = [NSMutableString string];
		for (int y = 0; y < NOISE_GRID_SIZE; y++) {
			for (int x = 0; x < NOISE_GRID_SIZE; x++) {
				[s appendFormat:@"%1.3f ", _noiseGrid[x][y]];
			}
			[s appendString:@"\n"];
		}
		NSLog(@"Grid:\n%@\n", s);
		
		for (int i = 0; i < 10; i++) {
			//NSLog(@"val: %f", [self noiseValueForPoint:CGPointMake(0.025*i, 0.000*i)]);
		}
		#endif
		
		/* Create lines */
		_lines = [NSMutableArray array];
		for (int i = 0; i < 100; i++) {
			PaintLine *line = [[PaintLine alloc] init];
			[self createNewLineParameters:line];
			[_lines addObject:line];
		}
		
		/* Add grain */
		_grainView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grain"]];
		_grainView.alpha = _colorGrain;
		[self addSubview:_grainView];
		
	}
	return self;
}


- (void) setImage:(UIImage *)image {
	_image = image;
	
	/* Destroy existing bitmap context */
	if (_bitmapContext) {
		CGContextRelease(_bitmapContext);
	}
	
	/* Destory memory */
	if (_bitmapMemory) {
		free(_bitmapMemory);
	}
	
	/* Create new one */
	_bitmapMemory  = malloc(image.size.width * image.size.height * 4);
	_bitmapContext = CGBitmapContextCreate(_bitmapMemory, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
	
	/* Now create the memory chunk for the original memory */
	if (_originalMemory) {
		free(_originalMemory);
	}
	
	/* Now save original image data into original memory */
	_originalW = image.size.width;
	_originalH = image.size.height;
	_originalMemory = malloc(_originalW * _originalH * 4);
	CGContextRef originalContext = CGBitmapContextCreate(_originalMemory, _originalW, _originalH, 8, _originalW * 4, CGColorSpaceCreateDeviceRGB(), (CGBitmapInfo)(kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big));
	CGContextDrawImage(originalContext, CGRectMake(0, 0, _originalW, _originalH), _image.CGImage);
	CGContextRelease(originalContext);
	
	/* Recalc scaling */
	[self recalculateScaling];
}

- (void) recalculateScaling {
	float origToFrameW = _originalW / self.bounds.size.width;
	float origToFrameH = _originalH / self.bounds.size.height;
	
	float shrink_ratio = 0;
	
	if (origToFrameW > origToFrameH) {
		/* Wider; needs to squeeze in */
		shrink_ratio = self.bounds.size.width / _originalW;
	} else {
		/* Higher; needs to squeeze down */
		shrink_ratio = self.bounds.size.height / _originalH;
	}
	
	float display_width  = _originalW * shrink_ratio;
	float display_height = _originalH * shrink_ratio;
	
	_imageDrawingScale = 1 / shrink_ratio;
	
	_imageDrawingRect = CGRectMake((self.bounds.size.width  - display_width)/2,
								   (self.bounds.size.height - display_height)/2,
								   display_width,
								   display_height);
}

- (void) fillNoiseGridFromX1:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2 depth:(int)depth {
	if (x1 == x2 && y1 == y2) return;
	
	int mx = (x1 + x2) / 2;
	int my = (y1 + y2) / 2;
	
	if (mx == x1 || mx == x2) return;
	if (my == y1 || my == y2) return;
	
	float jitter = _noiseJitter / powf(2, depth);
	
	_noiseGrid[mx][y1] = ((_noiseGrid[x1][y1] + _noiseGrid[x2][y1]) / 2) + floatBetween(-jitter, jitter);
	_noiseGrid[x1][my] = ((_noiseGrid[x1][y1] + _noiseGrid[x1][y2]) / 2) + floatBetween(-jitter, jitter);
	_noiseGrid[mx][y2] = ((_noiseGrid[x1][y2] + _noiseGrid[x2][y2]) / 2) + floatBetween(-jitter, jitter);
	_noiseGrid[x2][my] = ((_noiseGrid[x2][y1] + _noiseGrid[x2][y2]) / 2) + floatBetween(-jitter, jitter);
	_noiseGrid[mx][my] = ((_noiseGrid[mx][y1] + _noiseGrid[mx][y2] + _noiseGrid[x1][my] + _noiseGrid[x2][my]) / 4) + floatBetween(-jitter, jitter);
	
	[self fillNoiseGridFromX1:mx y1:my x2:x1 y2:y1 depth:depth+1];
	[self fillNoiseGridFromX1:mx y1:my x2:x1 y2:y2 depth:depth+1];
	[self fillNoiseGridFromX1:mx y1:my x2:x2 y2:y1 depth:depth+1];
	[self fillNoiseGridFromX1:mx y1:my x2:x2 y2:y2 depth:depth+1];
}

- (float) noiseValueForPoint:(CGPoint)point {
	float scaledX = point.x * (NOISE_GRID_SIZE-1);
	float scaledY = point.y * (NOISE_GRID_SIZE-1);
	
	int floorX = (int)scaledX;
	int floorY = (int)scaledY;
	
	int ceilX  = floorX + 1;  if (ceilX >= NOISE_GRID_SIZE) ceilX--;
	int ceilY  = floorY + 1;  if (ceilY >= NOISE_GRID_SIZE) ceilY--;
	
	float fX = scaledX - floorX;
	float fY = scaledY - floorY;
	float cX = ceilX - scaledX;
	float cY = ceilY - scaledY;
	
	//float d00  = sqrt(fX * fX + fY * fY);
	//float d10  = sqrt(cX * cX + fY * fY);
	//float d01  = sqrt(fX * fX + cY * cY);
	//float d11  = sqrt(fX * fX + fY * fY);
	
	//float totalDist = d00 + d01 + d10 + d11;
	
	//return (d00 / totalDist) * _noiseGrid[floorX][floorY] + ;
	
	return _noiseGrid[floorX][floorY] * (cX * cY) +
		   _noiseGrid[ceilX][floorY]  * (fX * cY) +
		   _noiseGrid[floorX][ceilY]  * (cX * fY) +
		   _noiseGrid[ceilX][ceilY]   * (fX * fY);
	
}

- (void) setPainting:(BOOL)painting {
	if (!_painting && painting) {
		/* Time to start! */
		_lastUpdateTime = CFAbsoluteTimeGetCurrent();
		[self performSelector:@selector(updatePainting) withObject:nil afterDelay:_paintingInterval];
	}
	
	_painting = painting;
	
	
}

- (void) createNewLineParameters:(PaintLine*)line {
	
	/* Set first-draw property */
	line.firstDraw = YES;
	
	/* Random position */
	line.currentPosition = CGPointMake(floatBetween(0, _originalW), floatBetween(0, _originalH));
	
	//line.speedVector = CGVectorMake(floatBetween(-200, 200), floatBetween(-200, 200));
	//line.speedVector = CGVectorMake(floatBetween(1000,1201), floatBetween(-50, 50));
	
	if (_originalW == 0 || _originalH == 0) {
		/* Don't have an image; no speed vector */
		line.speedVector = CGVectorMake(0, 0);
	} else {
	
		/* The noise grid will give us the noise angle at the particular x/y coord */
		float angle = (2 * M_PI) * [self noiseValueForPoint:CGPointMake(_noiseScale * line.currentPosition.x / _originalW, _noiseScale * line.currentPosition.y / _originalH)];
		
		/* And we modulate it by the angle scale */
		angle *= _lineAngleFieldWeight;
		
		/* Calculate velocity */
		line.speedVector = CGVectorMake(cosf(angle) * _lineSpeed * _imageDrawingScale, sinf(angle) * _lineSpeed * _imageDrawingScale);
	}
		
	/* Line width is multiplied by scale factor */
	line.lineWidth = _lineWidth * _imageDrawingScale;
	
	/* Lifetime */
	line.lifeRemaining = _lineLifetime * floatBetween(0.9, 1.1);
	
	/* Get color at point */
	if (_originalMemory) {
		int row = line.currentPosition.y;
		int col = line.currentPosition.x;
		uint8_t *colorReference = &_originalMemory[(col + row * _originalW) * 4];
		
		float r = colorReference[0] / 255.0;
		float g = colorReference[1] / 255.0;
		float b = colorReference[2] / 255.0;
		
		#if 1 /* This is the hue-or-not mode */
		if (floatBetween(0, 1) <= _colorOriginalProb) {
			/* Use original color */
			line.color = [UIColor colorWithRed:r green:g blue:b alpha:_lineAlpha];
		} else {
			/* Hued in color */
			float max = MAX(MAX(r, g), b);
			float min = MIN(MIN(r, g), b);
			
			float sum = max + min;
			float dif = max - min;
			
			float lightness  = sum / 2;
			float saturation = (max == min) ? 0 : ( (lightness > 0.5) ? (dif / (2 - sum)) : (dif / sum) );
			
			line.color = [UIColor colorWithHue:_colorHue saturation:_colorSaturation * saturation brightness:_colorLightness * lightness alpha:_lineAlpha];
		}
		#endif
		
		#if 0
		float max = MAX(MAX(r, g), b);
		float min = MIN(MIN(r, g), b);
		
		float sum = max + min;
		float dif = max - min;
		
		float lightness  = sum / 2;
		float saturation = (max == min) ? 0 : ( (lightness > 0.5) ? (dif / (2 - sum)) : (dif / sum) );
		saturation = (max == min) ? 0 : ( dif / (1 - abs(2 * lightness - 1)) );
		saturation += 0.1;
		lightness += 0.1;
		//lightness = 0.3 * r + 0.59 * g + 0.11 * b;
		
		float hue = 0;
		
		if (dif == 0) {
		
		} else if (max == r) {
			hue = (g - b) / dif + ( (g < b) ? 6 : 0 );
		} else if (max == g) {
			hue = (b - r) / dif + 2;
		} else {
			hue = (r - g) / dif + 4;
		}
		hue /= 6;
		
		line.color = [UIColor colorWithHue:hue saturation:saturation brightness:lightness alpha:_lineAlpha];
		//line.color = [UIColor colorWithRed:r green:g blue:b alpha:_lineAlpha];
		#endif
	} else {
		line.color = [UIColor blackColor];
	}
	
	/*
	static NSTimeInterval start = 0;
	if (start == 0) start = CFAbsoluteTimeGetCurrent();
	NSTimeInterval cur = CFAbsoluteTimeGetCurrent();
	double elap = cur - start;
	if (elap < 4) line.lineWidth = (5 - elap) * 20;
	*/
	
}

- (void) updatePainting {
	/* Time cycle */
	NSTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
	NSTimeInterval timeDiff = currentTime - _lastUpdateTime;
	_lastUpdateTime = currentTime;
	
	/* Update all of the lines */
	for (PaintLine *line in _lines) {
		NSTimeInterval remainingTime = timeDiff;
		while ( (remainingTime = [line paintInContext:_bitmapContext forTimeDuration:remainingTime]) > 0) {
			/* New line! */
			[self createNewLineParameters:line];
		}
	}
	
	
	/* Need to redraw */
	[self setNeedsDisplay];
	
	/* Keep painting? */
	if (_painting) {
		[self performSelector:@selector(updatePainting) withObject:nil afterDelay:_paintingInterval];
	}
}


- (void) trackFPS {
	_frameCount++;
	
	NSTimeInterval curr = CFAbsoluteTimeGetCurrent();
	NSTimeInterval diff = curr - _lastFPSCheck;
	
	if (diff > 1) {
		_lastFPSCheck = curr;
		NSLog(@"FPS: %d", _frameCount);
		_frameCount = 0;
	}
}


- (void)drawRect:(CGRect)rect {
	if (!_bitmapContext) return;
	
	[self trackFPS];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef cacheImage = CGBitmapContextCreateImage(_bitmapContext);
	CGContextDrawImage(context, _imageDrawingRect, cacheImage);
	CGImageRelease(cacheImage);
}


@end
