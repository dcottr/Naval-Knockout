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
    ActionHeavyCannon,
    ActionCannon,
    ActionTorpedo,
    ActionMine
};
typedef NSInteger Action;


@interface ShipCommandBar ()

@property (nonatomic, strong) SPQuad *background;
@property (nonatomic, strong) SPImage *commandBar;
@property (nonatomic, strong) SPTextField *shipName;
@property (nonatomic, strong) SPButton *lButton;
@property (nonatomic, strong) SPButton *rButton;
@property (nonatomic, strong) SPButton *spinButton;
@property (nonatomic, strong) SPButton *dropMineButton;
@property (nonatomic, strong) SPButton *cannonButton;
@property (nonatomic, strong) SPButton *heavyCannonButton;
@property (nonatomic, strong) SPButton *torpedoButton;
@property (nonatomic, strong) SPButton *radarOnButton;
@property (nonatomic, strong) SPButton *radarOffButton;

@property (nonatomic, strong) NSSet *validTileSelects;

@property (nonatomic, assign) Action selectedAction;

@property (nonatomic, weak) Game *game;

@end

@implementation ShipCommandBar

static SPTexture *commandBarTexture = nil;
static SPTexture *buttonTexture = nil;
static NSDictionary *shipNameMap = nil;

- (id)initWithGame:(Game *)game
{
    if (!shipNameMap) {
        shipNameMap = @{num(Cruiser): @"Cruiser", num(Destroyer): @"Destroyer", num(Torpedo): @"Torpedo Boat", num(Miner): @"Mine Layer", num(Radar): @"Radar Boat", num(BaseType): @"Base"};
    }
    if (!commandBarTexture)
        commandBarTexture = [SPTexture textureWithContentsOfFile:@"Glossy08.png"];
    if (!buttonTexture) {
        buttonTexture = [SPTexture textureWithContentsOfFile:@"green_button05.png"];
    }
    self = [super init];
    if (self) {
        _game = game;
        
        _background = [[SPQuad alloc] initWithWidth:Sparrow.stage.width height:90.0f color:0x000000];
        _background.y = 10.0f;
        [self addChild:_background];
        [_background setVisible:NO];

        _commandBar = [[SPImage alloc] initWithTexture:commandBarTexture];
        _commandBar.width = Sparrow.stage.width;
        _commandBar.height = 100.0f;
        [self addChild:_commandBar];
        [_commandBar setVisible:NO];
        
        _lButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Left"];
        [_lButton addEventListener:@selector(turnLeft:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _lButton.x = 30.0f;
        _lButton.y = 20.0f;
        [self addChild:_lButton];
        [_lButton setVisible:NO];
        
        _rButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Right"];
        [_rButton addEventListener:@selector(turnRight:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _rButton.x = 30.0f;
        _rButton.y = 20.0f + _lButton.y + _lButton.height;
        [self addChild:_rButton];
        [_rButton setVisible:NO];
        
        _cannonButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Cannon"];
        [_cannonButton addEventListener:@selector(shootCannon:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _cannonButton.x = _lButton.x * 2 + _lButton.width;
        _cannonButton.y = _lButton.y;
        [self addChild:_cannonButton];
        [_cannonButton setVisible:NO];
        
        _heavyCannonButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Heavy Cannon"];
        _heavyCannonButton.fontSize = 11;
        [_heavyCannonButton addEventListener:@selector(shootHeavyCannon:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _heavyCannonButton.x = _cannonButton.x;
        _heavyCannonButton.y = _cannonButton.y;
        [self addChild:_heavyCannonButton];
        [_heavyCannonButton setVisible:NO];

        _dropMineButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Mine"];
        [_dropMineButton addEventListener:@selector(dropMine:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _dropMineButton.x = _rButton.x * 2 + _lButton.width;
        _dropMineButton.y = _rButton.y;
        [self addChild:_dropMineButton];
        [_dropMineButton setVisible:NO];
        
        _radarOffButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Radar Off"];
        [_radarOffButton addEventListener:@selector(toggleOffRadar:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _radarOffButton.x = _dropMineButton.x;
        _radarOffButton.y = _dropMineButton.y;
        [self addChild:_radarOffButton];
        [_radarOffButton setVisible:NO];
        
        _radarOnButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Radar On"];
        [_radarOnButton addEventListener:@selector(toggleOnRadar:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _radarOnButton.x = _radarOffButton.x;
        _radarOnButton.y = _radarOffButton.y;
        [self addChild:_radarOnButton];
        [_radarOnButton setVisible:NO];
        
        _spinButton = [[SPButton alloc] initWithUpState:buttonTexture text:@"Spin"];
        [_spinButton addEventListener:@selector(spin:) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
        _spinButton.x = _rButton.x * 3 + _rButton.width + _cannonButton.width;
        _spinButton.y = _lButton.y;
        [self addChild:_spinButton];
        [_spinButton setVisible:NO];

        _shipName = [SPTextField textFieldWithWidth:100 height:20 text:@"Text"];
        _shipName.x = Sparrow.stage.width - 100;
        _shipName.y = 10;
        _shipName.color = 0xd3d3d3;
        [self addChild:_shipName];
        [_shipName setVisible:NO];
    }
    return self;
}

- (void)setSelected:(Ship *)ship
{
    [self deselect];
    _ship = ship;
    [_commandBar setVisible:YES];
    [_background setVisible:YES];
    _shipName.text = [shipNameMap objectForKey:num(ship.shipType)];
    [_shipName setVisible:YES];

    if (_game.currentStateType == StateTypeShipSetupLeft || _game.currentStateType == StateTypeShipSetupRight) {
        return;
    }
    if (ship.movementIsDisabled) {
        _lButton.enabled = NO;
        _rButton.enabled = NO;
        _spinButton.enabled = NO;
    }
    
    [_lButton setVisible:YES];
    [_rButton setVisible:YES];
    // Set validTileSelections Likes
    _selectedAction = ActionMove;
    _validTileSelects = [ship validMoveTiles];
    if (_ship.shipType == Miner) {
        [_dropMineButton setVisible:YES];
    }
    if ([_ship.shipWeapons indexOfObject:num(WeaponCannon)] != NSNotFound) {
        [_cannonButton setVisible:YES];
    }
    if ([_ship.shipWeapons indexOfObject:num(WeaponHeavyCannon)] != NSNotFound) {
        [_heavyCannonButton setVisible:YES];
    }
    if (_ship.shipType == Radar || _ship.shipType == Torpedo) {
        [_spinButton setVisible:YES];
    }
    if (ship.shipType == Radar) {
        if (ship.movementIsDisabled) {
            [_radarOffButton setVisible:YES];
        } else {
            [_radarOnButton setVisible:YES];
        }
    }
    
    [self setSelectableTiles];
}

- (void)deselect
{
    [self deselectTiles];
    _validTileSelects = nil;
    [_commandBar setVisible:NO];
    [_background setVisible:NO];
    [_lButton setVisible:NO];
    [_rButton setVisible:NO];
    _lButton.enabled = YES;
    _rButton.enabled = YES;
    [_shipName setVisible:NO];
    [_dropMineButton setVisible:NO];
    [_cannonButton setVisible:NO];
    [_heavyCannonButton setVisible:NO];
    [_spinButton setVisible:NO];
    _spinButton.enabled = YES;
    [_radarOnButton setVisible:NO];
    [_radarOffButton setVisible:NO];
    _ship = nil;
}

// Refresh GUI
- (void)reselect
{
    Ship *ship = _ship;
    [self deselect];
    [self setSelected:ship];
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
    [self didPerformAction];
}

- (void)turnLeft:(SPEvent *)event
{
    if (!_ship) {
        [self deselect];
        return;
    }
    
    [_ship turnLeft];
    [self didPerformAction];
}

- (void)spin:(SPEvent *)event
{
    if (!_ship) {
        [self deselect];
        return;
    }
    
    [_ship spin];
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
    if (_selectedAction == ActionCannon) {
        [self setSelected:_ship];
        return;
    }
    
    [self deselectTiles];
    
    _validTileSelects = [_ship validShootCannonTiles];
    [self setSelectableTiles];
    _selectedAction = ActionCannon;
}

- (void)shootHeavyCannon:(SPEvent *)event
{
    if (_selectedAction == ActionCannon) {
        [self setSelected:_ship];
        return;
    }
    
    [self deselectTiles];
    
    _validTileSelects = [_ship validShootCannonTiles];
    [self setSelectableTiles];
    _selectedAction = ActionHeavyCannon;
}

- (void)toggleOffRadar:(SPEvent *)event
{
    [_ship toggleSuperRadar:NO];
    [self didPerformAction];
}

- (void)toggleOnRadar:(SPEvent *)event
{
    [_ship toggleSuperRadar:YES];
    [self didPerformAction];
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
        } else if (_selectedAction == ActionCannon) {
            [tile performCannonAction];
        } else if (_selectedAction == ActionHeavyCannon) {
            [tile performHeavyCannonAction];
        }
        [self didPerformAction];
    }
    
    // Refreshes GUI after operation
    [self deselect];
    NSLog(@"Deselected");
}

- (void)didPerformAction
{
    [_game performedAction];
    [self deselect];
}


@end
