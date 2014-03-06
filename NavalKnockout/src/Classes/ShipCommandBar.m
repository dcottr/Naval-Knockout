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

@property (nonatomic, strong) Ship *ship;

@property (nonatomic, strong) NSSet *validTileSelects;

@property (nonatomic, assign) Action selectedAction;

@end

@implementation ShipCommandBar

static SPTexture *commandBarTexture = nil;

- (id)init
{
    if (!commandBarTexture)
        commandBarTexture = [SPTexture textureWithContentsOfFile:@"Glossy08.png"];
    if (!buttonTexture) {
        buttonTexture = [SPTexture textureWithContentsOfFile:@"button2.png"];
    }
    self = [super init];
    if (self) {
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
    
    // Set validTileSelections
    _selectedAction = ActionMove;
    _validTileSelects = [ship validMoveTiles];
    for (Tile *tile in _validTileSelects) {
        [tile setSelectable:YES];
    }
}

- (void)deselect
{
    for (Tile *oldTile in _validTileSelects) {
        [oldTile setSelectable:NO];
    }
    [_commandBar setVisible:NO];
    [_lButton setVisible:NO];
    [_rButton setVisible:NO];
    _ship = nil;
}

- (void)turnRight:(SPEvent *)event
{
    if (!_ship) {
        [self deselect];
        return;
    }
    
    [_ship turnRight];
}

- (void)turnLeft:(SPEvent *)event
{
    [_ship turnLeft];
}

- (void)selectTile:(Tile *)tile
{
    if (!_validTileSelects) {
        [self deselect];
        return;
    }
    
    if ([_validTileSelects containsObject:tile]) {
        [tile setVisible:NO];
        // Move to spot. if selectedAction is Move
        
    } else {
        [self deselect];
    }
}

- (void)performMoveActionTo:(Tile *)tile
{
    
}

@end
