//
//  PearlCCMenuItemBlock.m
//  Pearl
//
//  Created by Maarten Billemont on 08/06/11.
//  Copyright 2009 lhunath (Maarten Billemont). All rights reserved.
//

#import "PearlCCMenuItemBlock.h"
#import "PearlConfig.h"
#import "PearlGLUtils.h"


@implementation PearlCCMenuItemBlock



+ (PearlCCMenuItemBlock *)itemWithSize:(NSUInteger)size target:(id)target selector:(SEL)selector {

    return [[[PearlCCMenuItemBlock alloc] initWithSize:size target:target selector:selector] autorelease];
}

- (id)initWithSize:(NSUInteger)size target:(id)target selector:(SEL)selector {

    if (!(self = [super initWithTarget:target selector:selector]))
        return nil;

    self.contentSize = CGSizeMake(size, size);

    return self;
}

- (void)draw {

    [super draw];

    CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, @"PearlCCMenuItemBlock - draw");
   	CC_NODE_DRAW_SETUP();

    if (!self.isEnabled)
        ccDrawLine(CGPointZero, CC_POINT_POINTS_TO_PIXELS(CGPointFromCGSize(self.contentSize))); // make 5 thick?

    CHECK_GL_ERROR_DEBUG();
    CC_INCREMENT_GL_DRAWS(1);
   	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, @"PearlCCMenuItemBlock - draw");
}

@end
