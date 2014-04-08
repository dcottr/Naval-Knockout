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

@property (nonatomic, strong) SPQuad *selectableOverlay;

@property (nonatomic, strong) SPImage *shipSegmentImage;

@property (nonatomic, strong) SPSprite *healthOverlayContent;
@property (nonatomic, strong) SPQuad *damagedOverlay;
@property (nonatomic, strong) SPQuad *destroyedOverlay;
@property (nonatomic, strong) SPQuad *collisionOverlay;


@end

@implementation ShipSegment

static SPTexture *waterTexture = nil;
static SPTexture *backShipTexture = nil;
static SPTexture *middleShipTexture = nil;
static SPTexture *frontShipTexture = nil;
static SPTexture *frontBaseShipTexture = nil;


- (id)initWithIndex:(ShipSegmentIndex)index ship:(Ship *)ship
{
    if (!waterTexture) {
        waterTexture = [SPTexture textureWithContentsOfFile:@"watertile.jpeg"];
    }
    if (!backShipTexture) {
        backShipTexture = [SPTexture textureWithContentsOfFile:@"shipBack.png"];
    }
    if (!middleShipTexture) {
        middleShipTexture = [SPTexture textureWithContentsOfFile:@"shipMid.png"];
    }
    if (!frontShipTexture) {
        frontShipTexture = [SPTexture textureWithContentsOfFile:@"shipFront.png"];
    }
    if (!frontBaseShipTexture) {
        frontBaseShipTexture = [SPTexture textureWithContentsOfFile:@"shipFrontBase.png"];
    }


    self = [super init];
    if (self) {
        _ship = ship;
        
        SPTexture *shipSegmentTexture;
        if (index == ShipSegmentIndexBack) {
            shipSegmentTexture = backShipTexture;
        } else if (index == ShipSegmentIndexMid) {
            shipSegmentTexture = middleShipTexture;
        } else {
            if (ship.shipType == BaseType) {
                shipSegmentTexture = frontBaseShipTexture;
            } else {
                shipSegmentTexture = frontShipTexture;
            }
        }
        
        _healthOverlayContent = [[SPSprite alloc] init];
        _healthOverlayContent.width = 32.0f;
        _healthOverlayContent.height = 32.0f;
        [self addChild:_healthOverlayContent];
        
        _damagedOverlay = [[SPQuad alloc] initWithWidth:32.0f height:32.0f color:0xffff00];
        [_healthOverlayContent addChild:_damagedOverlay];
        [_damagedOverlay setVisible:NO];
        
        _destroyedOverlay = [[SPQuad alloc] initWithWidth:32.0f height:32.0f color:0x000000];
        [_healthOverlayContent addChild:_destroyedOverlay];
        [_destroyedOverlay setVisible:NO];

        _collisionOverlay = [[SPQuad alloc] initWithWidth:32.0f - 7.0f height:32.0f - 7.0f color:0xff0000];
        [self addChild:_collisionOverlay];
        [_collisionOverlay setVisible:NO];
        
        _shipSegmentImage = [[SPImage alloc] initWithTexture:shipSegmentTexture];
        _shipSegmentImage.width = 32.0f;
        _shipSegmentImage.height = 32.0f;
        [self addChild:_shipSegmentImage];

        _selectableOverlay = [[SPQuad alloc] initWithWidth:self.width height:self.height color:0x00FF00];
        _selectableOverlay.alpha = 0.5f;
        _selectableOverlay.width = 32.0f;
        _shipSegmentImage.height = 32.0f;
        [self addChild:_selectableOverlay];
        [_selectableOverlay setVisible:NO];
        _health = 2;
    }
    return self;
}

- (void)setFogOfWar:(BOOL)foggy
{
    [_shipSegmentImage setVisible:foggy];
    [_healthOverlayContent setVisible:foggy];
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
            [self updateSegmentDamage];
            return;
        }
    }
    _health = 0;
    [self updateSegmentDamage];
}

- (void)hitByHeavyCannon
{
    _health = 0;
    [self updateSegmentDamage];
}

- (void)hitByKamikaze
{
    _health = 0;
    [self updateSegmentDamage];
}


- (void)hitByMine
{
    _health = 0;
    [self updateSegmentDamage];
    for (ShipSegment *segment in _ship) {
        if (segment.health > 0) {
            segment.health = 0;
            [segment updateSegmentDamage];
            return;
        }
    }
}

- (void)displayNotify:(BOOL)display
{
    [_collisionOverlay setVisible:display];
}

- (void)setTile:(Tile *)tile
{
    _tile = tile;
    [self displayNotify:NO];
}

- (void)updateSegmentDamage
{
    [_destroyedOverlay setVisible:NO];
    [_damagedOverlay setVisible:NO];
    if(_health == 0) {
        [_destroyedOverlay setVisible:YES];
    } else if (_health == 1) {
        [_damagedOverlay setVisible:YES];
    }
}


@end
