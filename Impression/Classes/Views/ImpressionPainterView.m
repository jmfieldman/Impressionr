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
		
		/* Set default attributes */
		_lineWidth = 20;
		
		
		/* Create lines */
		_lines = [NSMutableArray array];
		for (int i = 0; i < 400; i++) {
			PaintLine *line = [[PaintLine alloc] init];
			[self createNewLineParameters:line];
			[_lines addObject:line];
		}
		
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
	line.currentPosition = CGPointMake(floatBetween(0, _originalW), floatBetween(0, _originalH));
	line.speedVector = CGVectorMake(floatBetween(-200, 200), floatBetween(-200, 200));
	line.speedVector = CGVectorMake(floatBetween(1000,1201), floatBetween(-50, 50));
	line.lineWidth = _lineWidth;
	line.lifeRemaining = floatBetween(0.05, 0.1);
	
	/* Get color at point */
	if (_originalMemory) {
		int row = line.currentPosition.y;
		int col = line.currentPosition.x;
		uint8_t *colorReference = &_originalMemory[(col + row * _originalW) * 4];
		
		float r = colorReference[0] / 255.0;
		float g = colorReference[1] / 255.0;
		float b = colorReference[2] / 255.0;
		
		line.color = [UIColor colorWithRed:r green:g blue:b alpha:0.5];
	} else {
		line.color = [UIColor blackColor];
	}
	
	static NSTimeInterval start = 0;
	if (start == 0) start = CFAbsoluteTimeGetCurrent();
	NSTimeInterval cur = CFAbsoluteTimeGetCurrent();
	double elap = cur - start;
	if (elap < 4) line.lineWidth = (5 - elap) * 20;
	
	
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


- (void)drawRect:(CGRect)rect {
	if (!_bitmapContext) return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef cacheImage = CGBitmapContextCreateImage(_bitmapContext);
	CGContextDrawImage(context, self.bounds, cacheImage);
	CGImageRelease(cacheImage);
}


@end
