//
//  ShipSegment.m
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-14.
//
//

#import "Ship.h"
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
        _health = 2;
    }
    return self;
}

- (void)setFogOfWar:(BOOL)foggy
{
    if (_ship) {
        NSLog(@"Ship Direction: %ld", (long)_ship.dir);
    }
    
    _overlayImage.pivotX = _overlayImage.width/2.0f;
    _overlayImage.pivotY = _overlayImage.height/2.0f;
    _overlayImage.x = _overlayImage.width/2.0f;
    _overlayImage.y = _overlayImage.height/2.0f;
    
    switch (_ship.dir) {
        case Up:
            _overlayImage.rotation = 0;
            break;
        case Right:
            _overlayImage.rotation = -M_PI/2.0;
            break;
        case Left:
            _overlayImage.rotation = M_PI/2.0;
            break;
        case Down:
            _overlayImage.rotation = M_PI;
            break;
        default:
            break;
    }
    
    [_overlayImage setVisible:!foggy];
}

- (void)setSelectable:(BOOL)selectable
{
    [_selectableOverlay setVisible:selectable];
}

- (void)hitByCannon
{
    if (_health == 2) {
        if (_ship.shipArmour == ArmourHeavy) {
            _health = 1;
            [self updateTileDamage];
            return;
        }
    }
    
    NSLog(@"Hit by cannon, new health: %d", _health);
    _health = 0;
    [self updateTileDamage];
    return;
}

- (void)updateTileDamage
{
    if(_health == 0) {
        [_tile setDestroyed];
    } else if (_health == 1) {
        [_tile setDamaged];
    } else {
        [_tile setClear];
    }
}


@end
