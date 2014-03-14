//
//  ShipSegment.m
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-14.
//
//

#import "ShipSegment.h"
#import "Tile.h"

@interface ShipSegment ()

@property (nonatomic, strong) SPImage *overlayImage;
@property (nonatomic, strong) SPQuad *selectableOverlay;

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
        
        _selectableOverlay = [[SPQuad alloc] initWithWidth:self.width height:self.height color:0x00FF00];
        _selectableOverlay.alpha = 0.5f;
        [self addChild:_selectableOverlay];
        [_selectableOverlay setVisible:NO];
    }
    return self;
}

- (void)setFogOfWar:(BOOL)foggy
{
    [_overlayImage setVisible:!foggy];
}

- (void)setSelectable:(BOOL)selectable
{
    [_selectableOverlay setVisible:selectable];
}

@end
