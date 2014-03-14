//
//  ShipCommandBar.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "ShipCommandBar.h"
#import "Ship.h"
#import "Tile.h"
#import "Game.h"

enum {
    ActionMove,
    ActionHeavyCanon,
    ActionCanon,
    ActionTorpedo,
    ActionMine
};
typedef NSInteger Action;


@interface ShipCommandBar ()

@property (nonatomic, strong) SPImage *commandBar;
@property (nonatomic, strong) SPButton *lButton;
@property (nonatomic, strong) SPButton *rButton;
@property (nonatomic, strong) SPButton *dropMineButton;
@property (nonatomic, strong) SPButton *cannonButton;


@property (nonatomic, strong) Ship *ship;

@property (nonatomic, strong) NSSet *validTileSelects;

@property (nonatomic, assign) Action selectedAction;

@property (nonatomic, weak) Game *game;

@end

@implementation ShipCommandBar

static SPTexture *commandBarTexture = nil;

- (id)initWithGame:(Game *)game
{
    if (!commandBarTexture)
        commandBarTexture = [SPTexture textureWithContentsOfFile:@"Glossy08.png"];
    if (!buttonTexture) {
        buttonTexture = [SPTexture textureWithContentsOfFile:@"button2.png"];
    }
    self = [super init];
    if (self) {
        _game = game;
        _commandBar = [[SPImage alloc] initWithTexture:commandBarTexture];
        _commandBar.width = Sparrow.stage.width;
        _commandBar.height = 100.0f;
        [self addChild:_commandBar];
        [_commandBar setVisible:NO];
        
        _lButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Left"];
        [_lButton addEventListener:@selector(turnLeft:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _lButton.x = 30.0f;
        _lButton.y = 5.0f;
        [self addChild:_lButton];
        [_lButton setVisible:NO];
        
        _rButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Right"];
        [_rButton addEventListener:@selector(turnRight:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _rButton.x = 30.0f;
        _rButton.y = 5.0f + _lButton.y + _lButton.height;
        [self addChild:_rButton];
        [_rButton setVisible:NO];
        
        _dropMineButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Mine"];
        [_dropMineButton addEventListener:@selector(dropMine:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _dropMineButton.x = 30.0f * 2 + _lButton.width;
        _dropMineButton.y = 5.0f + _lButton.y;
        [self addChild:_dropMineButton];
        [_dropMineButton setVisible:NO];
        
        _cannonButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Cannon"];
        [_cannonButton addEventListener:@selector(shootCannon:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _cannonButton.x = 30.0f * 2 + _lButton.width;
        _cannonButton.y = 5.0f + _lButton.y + _lButton.height;
        [self addChild:_cannonButton];
        [_cannonButton setVisible:NO];

        
    }
    return self;
}

static SPTexture *buttonTexture = nil;
- (void)setSelected:(Ship *)ship
{
    
    [self deselect];
    _ship = ship;
    [_commandBar setVisible:YES];
    [_lButton setVisible:YES];
    [_rButton setVisible:YES];
    // Set validTileSelections Likes
    _selectedAction = ActionMove;
    _validTileSelects = [ship validMoveTiles];
    if (_ship.shipType == Miner) {
        [_dropMineButton setVisible:YES];
    } else if ([_ship.shipWeapons indexOfObject:num(WeaponCannon)] != NSNotFound) {
        [_cannonButton setVisible:YES];
    }
    [self setSelectableTiles];
}

- (void)deselect
{
    [self deselectTiles];
    [_commandBar setVisible:NO];
    [_lButton setVisible:NO];
    [_rButton setVisible:NO];
    [_dropMineButton setVisible:NO];
    [_cannonButton setVisible:NO];
    _ship = nil;
}

// Hides visual of valid selectable tiles
- (void)deselectTiles
{
    for (Tile *oldTile in _validTileSelects) {
        [oldTile setSelectable:NO];
    }
}

// Shows visual of valid selectable tiles
- (void)setSelectableTiles
{
    for (Tile *tile in _validTileSelects) {
        [tile setSelectable:YES];
    }
}

- (void)turnRight:(SPEvent *)event
{
    if (!_ship) {
        [self deselect];
        return;
    }
    
    [_ship turnRight];
    [self setSelected:_ship];
    [self didPerformAction];
}

- (void)turnLeft:(SPEvent *)event
{
    if (!_ship) {
        [self deselect];
        return;
    }
    
    [_ship turnLeft];
    [self setSelected:_ship];
    [self didPerformAction];
}

- (void)dropMine:(SPEvent *)event
{
    if (_selectedAction == ActionMine) {
        [self setSelected:_ship];
        return;
    }
    [self deselectTiles];
    _validTileSelects = [_ship validDropMineTiles];
    [self setSelectableTiles];
    _selectedAction = ActionMine;
}

- (void)shootCannon:(SPEvent *)event
{
    if (_selectedAction == ActionCanon) {
        [self setSelected:_ship];
        return;
    }
    
    [self deselectTiles];
    
    _validTileSelects = [_ship validShootCannonTiles];
    [self setSelectableTiles];
    _selectedAction = ActionCanon;

}

- (void)selectTile:(Tile *)tile
{
    if (!_validTileSelects) {
        [self deselect];
        return;
    }
    
    if ([_validTileSelects containsObject:tile]) {
        if (_selectedAction == ActionMove) {
            [_ship performMoveActionTo:tile];
        } else if (_selectedAction == ActionMine) {
            [tile performMineAction];
        } else if (_selectedAction == ActionCanon) {
            [tile performCannonAction];
        }
        [self didPerformAction];
    }
    
    // Refreshes GUI after operation
    [self deselect];
}

- (void)didPerformAction
{
    [_game performedAction];
}


@end
