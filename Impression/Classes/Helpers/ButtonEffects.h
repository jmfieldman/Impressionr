//
//  ButtonEffects.h
//  ExperimentF
//
//  Created by Jason Fieldman on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ButtonEffect : NSObject {
}
- (void) attachToControl:(UIControl*)control;
@end


@interface ButtonEffectsExpander : ButtonEffect {
}
SINGLETON_INTR(ButtonEffectsExpander);
@end
