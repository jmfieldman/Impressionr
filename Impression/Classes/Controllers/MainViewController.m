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

@implementation MainViewController

SINGLETON_IMPL(MainViewController);

- (id)init {
	if ((self = [super init])) {
		
		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor redColor];
		
		_paintView = [[ImpressionPainterView alloc] initWithFrame:self.view.bounds];
		_paintView.image = [UIImage imageNamed:@"test_image1.jpg"];
		_paintView.painting = YES;
		[self.view addSubview:_paintView];
	}
	return self;
}


@end
