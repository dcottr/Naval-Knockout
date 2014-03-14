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

@interface Tile ()

@property (nonatomic, weak) Game * game;
@property (nonatomic, strong) SPQuad *selectableOverlay;

@property (nonatomic, strong) Mine *mine;

@property (nonatomic, strong) SPQuad *collisionOverlay;

@property (nonatomic, strong) SPQuad *damagedOverlay;
@property (nonatomic, strong) SPQuad *sunkOverlay;



@end

@implementation Tile

static SPTexture *waterTexture = nil;
- (id)initWithGame:(Game *)game row:(int)r column:(int)c
{
    if (!waterTexture) {
        waterTexture = [SPTexture textureWithContentsOfFile:@"watertile.jpeg"];
    }
    self = [super init];
    if (self) {
        _game = game;
        _row = r;
        _col = c;
        
        SPImage *image = [[SPImage alloc] initWithTexture:waterTexture];
        image.width = _game.tileSize;
        image.height = _game.tileSize;
        
        
        [self addChild:image];
        _damagedOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize height:_game.tileSize color:0xffff00];
        [self addChild:_damagedOverlay];
        [_damagedOverlay setVisible:NO];
        
        _sunkOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize height:_game.tileSize color:0x000000];
        [self addChild:_sunkOverlay];
        [_sunkOverlay setVisible:NO];
        
        _collisionOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize - 7.0f height:_game.tileSize - 7.0f color:0xff0000];
        [self addChild:_collisionOverlay];
        [_collisionOverlay setVisible:NO];
        
        _selectableOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize height:_game.tileSize color:0x00FF00];
        [self addChild:_selectableOverlay];
        [_selectableOverlay setVisible:NO];
    }
    return self;
}


- (void)setSelectable:(BOOL)selectable
{
    [_selectableOverlay setVisible:selectable];
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
}

- (void)performCannonAction
{
    if (_myShip) {
        NSLog(@"Hit at row: %d, col: %d with ship: %@", _row, _col, _myShip);
        [_myShip hitByCannon];
    }
    [self displayCannonHit:YES];
    [_game notifyCannonCollision:self];
}

- (void)setDamaged
{
    [_damagedOverlay setVisible:YES];
}
- (void)setDestroyed
{
    [_sunkOverlay setVisible:YES];
}
- (void)setClear
{
    if (_sunkOverlay) {
        [_sunkOverlay setVisible:NO];
    }
    if (_damagedOverlay) {
        [_damagedOverlay setVisible:NO];
    }
}


// Yellow: 0xffff00

@end
