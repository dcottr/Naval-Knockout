//
//  Tile.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-05.
//
//

#import "Tile.h"
#import "Game.h"
#import "Mine.h"
#import "Ship.h"
#import "ShipSegment.h"

@interface Tile ()

@property (nonatomic, weak) Game * game;
@property (nonatomic, strong) SPQuad *selectableOverlay;

@property (nonatomic, strong) Mine *mine;

@property (nonatomic, strong) SPQuad *collisionOverlay;

@property (nonatomic, strong) SPQuad *sunkOverlay;

@property (nonatomic, assign) BOOL fogOfWarVisibility;

@property (nonatomic, strong) SPSprite *content;

@property (nonatomic, strong) SPImage *backgroundImage;


@end

@implementation Tile


static SPTexture *waterTexture = nil;
static SPTexture *reefTexture = nil;
static SPTexture *visTexture = nil;
static NSDictionary *reefPositions = nil;

- (id)initWithGame:(Game *)game row:(int)r column:(int)c
{
    if (!waterTexture) {
        waterTexture = [SPTexture textureWithContentsOfFile:@"watertile.jpeg"];
    }
	if (!reefTexture){
        reefTexture = [SPTexture textureWithContentsOfFile:@"reef.png"];
	}
	if (!visTexture){
        visTexture= [SPTexture textureWithContentsOfFile:@"visible.png"];
	}
    
	[self initReef];
    self = [super init];
    if (self) {
        _game = game;
        _row = r;
        _col = c;
        _fogOfWarVisibility = NO;
        
        // is this a reef?
        if( [[reefPositions objectForKey:num(r)] containsObject:num(c)] ){
            _reef = YES;
            _backgroundImage = [[SPImage alloc] initWithTexture:reefTexture];
        }
        else{
            _backgroundImage = [[SPImage alloc] initWithTexture:waterTexture];
        }
        
        _backgroundImage.width = _game.tileSize;
        _backgroundImage.height = _game.tileSize;
        [self addChild:_backgroundImage];
        
        _content = [[SPSprite alloc] init];
        _content.width = _game.tileSize;
        _content.height = _game.tileSize;
        [self addChild:_content];
        [_content setVisible:_fogOfWarVisibility];
                
        _collisionOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize - 7.0f height:_game.tileSize - 7.0f color:0xff0000];
        [_content addChild:_collisionOverlay];
        [_collisionOverlay setVisible:YES];
        
        _selectableOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize height:_game.tileSize color:0x00FF00];
        [self addChild:_selectableOverlay];
        _selectableOverlay.alpha = 0.5f;
        [_selectableOverlay setVisible:NO];
        _sunk = NO;
    }
    return self;
}
- (void)cleanTile
{
    _myShipSegment = nil;
    _myShip = nil;
    _sunk = NO;
    _backgroundImage.alpha = 1.0f;
    [self displayCannonHit:NO];
    [self fogOfWar:NO];
}

- (void)setSelectable:(BOOL)selectable
{
    if (_myShipSegment) {
        [_selectableOverlay setVisible:NO];
        [_myShipSegment setSelectable:selectable];
    } else {
        [_selectableOverlay setVisible:selectable];
    }
}

- (void)performMineAction
{
    _mine = [[Mine alloc] initWithTile:self];
    _hasMine = YES;
    [self addChild:_mine];
}

- (void)displayCannonHit:(BOOL)display
{
    [_collisionOverlay setVisible:display];
    if (display) {
        [self fogOfWar:YES];
    }
    if (_myShipSegment) {
        [_myShipSegment displayCannonHit:display];
    }
}

- (void)performCannonAction
{
    [_content setVisible:YES];
    if (_myShipSegment) {
        [_myShipSegment hitByCannon];
    }
  [self notifyEvent];
}

- (void)performHeavyCannonAction
{
    [_content setVisible:YES];
    if (_myShipSegment) {
        [_myShipSegment hitByHeavyCannon];
    }
    [self notifyEvent];
}

- (void)notifyEvent
{
  [self displayCannonHit:YES];
  [_game notifyCannonCollision:self];
}


- (void)initReef
{
    if (!reefPositions){
        reefPositions = @{num(6):@[num(10),num(11)], // reef space occupies rows 3 - 26, cols 10-19
                          num(7):@[num(12),num(13)],
                          num(8):@[num(10),num(11),num(12)],
                          num(9):@[num(20)],
                          num(10):@[num(19),num(18)],
                          num(11):@[num(17),num(16)],
                          num(12):@[num(13),num(14),num(15),num(16)],
                          num(14):@[num(14),num(15),num(16)],
                          num(16):@[num(11)],
                          num(17):@[num(10)],
                          num(24):@[num(19),num(10),num(12)],
                          };
    }
}

//- (void)setDamaged
//{
//    [_damagedOverlay setVisible:YES];
//}
//- (void)setDestroyed
//{
//    [_destroyedOverlay setVisible:YES];
//}

- (void)setSunk
{
    NSLog(@"Set sunk!");
    _backgroundImage.alpha = 0.5f;
    _sunk = YES;
}


- (void)fogOfWar:(BOOL)visible
{
    if (_myShipSegment) {
        NSLog(@"Ship should be invisible");
        [_myShipSegment setFogOfWar:visible];
    }
    [_content setVisible:visible];
    
    if (!_reef) {
        if (visible) {
            _backgroundImage.texture = visTexture;
        } else {
            _backgroundImage.texture = waterTexture;
        }
    }
    
    _fogOfWarVisibility = visible;
}


// Yellow: 0xffff00

@end
