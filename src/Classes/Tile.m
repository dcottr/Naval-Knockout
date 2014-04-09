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

@property (nonatomic, weak) Mine *triggerMine;

@property (nonatomic, strong) SPQuad *notifyOverlay;

@property (nonatomic, strong) SPQuad *sunkOverlay;

@property (nonatomic, assign) BOOL fogOfWarVisibility;

@property (nonatomic, strong) SPSprite *content;

@property (nonatomic, strong) SPImage *backgroundImage;

@property (nonatomic, strong) SPImage *reefImage;

@end

@implementation Tile


static SPTexture *waterTexture = nil;
static SPTexture *reefTexture = nil;
static SPTexture *visTexture = nil;

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
    
    self = [super init];
    if (self) {
        _game = game;
        _row = r;
        _col = c;
        _fogOfWarVisibility = NO;
        
        _backgroundImage = [[SPImage alloc] initWithTexture:waterTexture];
        _backgroundImage.width = _game.tileSize;
        _backgroundImage.height = _game.tileSize;
        [self addChild:_backgroundImage];
        
        _reefImage = [[SPImage alloc] initWithTexture:reefTexture];
        _reefImage.width = _game.tileSize;
        _reefImage.height = _game.tileSize;
        _reefImage.x = 0;
        _reefImage.y = 0;
        [self addChild:_reefImage];
        [_reefImage setVisible:NO];
        _reef = NO;
        
        _content = [[SPSprite alloc] init];
        _content.width = _game.tileSize;
        _content.height = _game.tileSize;
        [self addChild:_content];
        [_content setVisible:_fogOfWarVisibility];
        
        _notifyOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize - 7.0f height:_game.tileSize - 7.0f color:0xff0000];
        [_content addChild:_notifyOverlay];
        [_notifyOverlay setVisible:YES];
        
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
    if (_mine) {
        [self removeMine];
    }
    _triggerMine = nil;
    [self setReef:NO];
    _backgroundImage.alpha = 1.0f;
    [self displayCannonHit:NO];
    [self fogOfWar:NO];
    [self setSonar:NO];
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

- (void)performMineAction:(Ship *)ship
{
    if (_mine) {
        [self removeMine];
        ship.mineCount++;
        // Remove mine.
    } else {
        if (ship.mineCount < 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You've used all your mines" message:@"Try picking mines up!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            ship.mineCount--;
            [self hardSetMine];
        }
    }
}

- (void)hardSetMine
{
    _mine = [[Mine alloc] initWithTile:self];
    _triggerMine = _mine;
    [self addChild:_mine];
}

- (void)removeMine
{
    if (_mine) {
        [self removeChild:_mine];
        _mine = nil;
        NSLog(@"Deleted Mine");
    }
}

- (void)displayCannonHit:(BOOL)display
{
    [_notifyOverlay setVisible:display];
    if (display) {
        [self fogOfWar:YES];
    }
    if (_myShipSegment) {
        [_myShipSegment displayNotify:display];
    }
}

- (void)performCannonAction
{
    [_content setVisible:YES];
    if (_myShipSegment) {
        [_myShipSegment hitByCannon];
    }
    [self removeMine];
    [self notifyEvent];
}

- (void)performHeavyCannonAction
{
    [_content setVisible:YES];
    if (_myShipSegment) {
        [_myShipSegment hitByHeavyCannon];
    }
    [self removeMine];
    [self notifyEvent];
}

- (BOOL)performTorpedoAction:(Direction)dir
{
    if (!(_reef || _mine || _myShipSegment)) {
        return NO;
    }
    [_content setVisible:YES];
    if (_myShipSegment) {
        [_myShipSegment hitByTorpedo:dir];
    }
    [self removeMine];
    [self notifyEvent];
    return YES;
}

- (void)notifyEvent
{
    [self displayCannonHit:YES];
    [self setSonar:YES];
    [_game notifyCannonCollision:self];
}

- (void)setSunk
{
    NSLog(@"Set sunk!");
    _backgroundImage.alpha = 0.5f;
    _sunk = YES;
}

- (void)setReef:(BOOL)reef
{
    if (reef == _reef) {
        return;
    }
    _reef = reef;
    [_reefImage setVisible:reef];
}

- (void)fogOfWar:(BOOL)visible
{
    if (_myShipSegment) {
        if (_myShipSegment.ship.shipType == BaseType) {
            visible = YES;
        }
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

- (void)setSonar:(BOOL)visible
{
    if (_mine) {
        [_mine setVisible:visible];
    }
}

- (BOOL)isBase
{
    return (_myShipSegment && !_myShipSegment.ship.isEnemyShip && _myShipSegment.ship.shipType == BaseType);
}

- (void)addMineTrigger:(Mine *)mine
{
    _triggerMine = mine;
}

- (BOOL)collide:(Ship *)ship shipSegment:(ShipSegment *)segment
{
    
    if (_triggerMine || _mine) {
        if (ship.shipType == Miner) {
            if (_mine) {
                [self notifyEvent];
                return YES;
            }
        } else {
            [_triggerMine explode:segment];
            return YES;
        }
    }
    if (_reef) {
        [self notifyEvent];
        return YES;
    }
    if (_myShipSegment) {
        if (![_myShipSegment.ship isEqual:ship]) {
            [self notifyEvent];
            return YES;
        }
    }
    
    return NO;
}

- (void)performKamikazeAction
{
    [_content setVisible:YES];
    Tile *tile;
    for (int row = _row - 1; row < _row + 2; row++) {
        for (int col = _col - 1; col < _col + 2; col++) {
            tile = [_game tileAtRow:row col:col];
            if (!(row == _row && col == _col) && tile && tile.myShipSegment) {
                NSLog(@"Haha, boom: %d, %d", row, col);
                [self setFogOfWarVisibility:YES];
                [tile.myShipSegment hitByKamikaze];
            }
        }
    }
    [_content setVisible:YES];
    [self notifyEvent];
}

@end
