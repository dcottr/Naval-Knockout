//
//  ShipSegment.m
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-14.
//
//

#import "ShipSegment.h"

@interface ShipSegment ()

@property (nonatomic, strong) SPImage *overlayImage;

@end

@implementation ShipSegment

static SPTexture *waterTexture = nil;

- (id)init
{
    if (!waterTexture) {
        waterTexture = [SPTexture textureWithContentsOfFile:@"watertile.jpeg"];
    }

    self = [super init];
    if (self) {
        _overlayImage = [[SPImage alloc] initWithTexture:waterTexture];
        [self addChild:_overlayImage];
        [_overlayImage setVisible:NO];
//        quad.x = 5;
//        quad.y = 5;
//        [self setVisible:YES];
    }
    return self;
}

- (void)setFogOfWar:(BOOL)foggy
{
    [_overlayImage setVisible:!foggy];
}

@end
