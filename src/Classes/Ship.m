//
//  Ship.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-02.
//
//

#import "Ship.h"
#import "Game.h"
#import "ShipsTray.h"
#import "ShipCommandBar.h"
#import "Tile.h"

#include <math.h>


@interface Ship () {
    bool isGrabbed;
    bool isDragged;
    float offsetX;
    float offsetY;
}

@property (nonatomic, weak) ShipsTray *trayContainer;
@property (nonatomic, weak) SPSprite *gridContainer;
@property (nonatomic, weak) Game *gameContainer;


@property (nonatomic, strong) SPImage *shipImage;

@property (nonatomic, assign) Direction dir;
@property (nonatomic, assign) int baseRow;
@property (nonatomic, assign) int baseColumn;
@property (nonatomic, assign) int shipLength;
@property (nonatomic, assign) int shipSpeed;
@property (nonatomic, assign) ArmourType shipArmour;
@property (nonatomic, strong) NSArray *shipWeapons;


@end

static SPTexture *shipTexture = nil;
static NSDictionary *shipLengthMap = nil;
static NSDictionary *shipSpeedMap = nil;
static NSDictionary *shipArmourMap = nil;
static NSDictionary *shipWeaponsMap = nil;
static BOOL shipTypeMapsInitialized = NO;


@implementation Ship

+ (void)initShipTypeMaps
{
    if (!shipTypeMapsInitialized) {
        shipLengthMap = @{num(Cruiser): num(5), num(Destroyer): num(4), num(Torpedo): num(3), num(Miner): num(2), num(Radar): num(3)};
        shipSpeedMap = @{num(Cruiser): num(10), num(Destroyer): num(8), num(Torpedo): num(9), num(Miner): num(6), num(Radar): num(3)};
        shipArmourMap = @{num(Cruiser): num(ArmourHeavy), num(Destroyer): num(ArmourNormal), num(Torpedo): num(ArmourNormal), num(Miner): num(ArmourHeavy), num(Radar): num(ArmourNormal)};
        shipWeaponsMap = @{num(Cruiser): @[num(WeaponHeavyCannon)], num(Destroyer): @[num(WeaponCannon), num(WeaponTorpedo)], num(Torpedo): @[num(WeaponCannon), num(WeaponTorpedo)], num(Miner): @[num(WeaponCannon), num(WeaponMine)], num(Radar): @[num(WeaponCannon)]};
        shipTypeMapsInitialized = YES;
    }
}

- (id)initWithGame:(Game *)game type:(ShipType)type
{
    if (!shipTexture)
        shipTexture = [SPTexture textureWithContentsOfFile:@"ship_small_body.png"];
    
    [Ship initShipTypeMaps];
    
    if ((self = [super init]))
    {
        _shipType = type;
        _shipLength = [[shipLengthMap objectForKey:num(type)] intValue];
        _shipSpeed = [[shipSpeedMap objectForKey:num(type)] intValue];
        _shipArmour = [[shipArmourMap objectForKey:num(type)] intValue];
        _shipWeapons = [shipWeaponsMap objectForKey:num(type)];
        
        _shipImage = [[SPImage alloc] initWithTexture:shipTexture];
        
        
        _shipImage.width = 32;
        _shipImage.height = 32 * _shipLength;
        _dir = Up;
        [self addChild:_shipImage];
        _gameContainer = game;
        _trayContainer = game.shipsTray;
        _gridContainer = game.content;
        [self setup];
    }
    return self;
}

- (void)setup
{
    [self addEventListener:@selector(dragFromTray:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    self.pivotX = self.width / 2.0f;
    self.pivotY = self.height / 2.0f;
    
}


- (void)dragFromTray:(SPTouchEvent *)event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
	SPTouch *drag = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
	SPTouch *touchUp = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
	if (touch) {
        // Tapped ship in tray.
	} else if (drag) {
        if (!isGrabbed) {
            [_gameContainer addChild:self];
            isGrabbed = YES;
        }
		if (isGrabbed) {
			SPPoint *dragPosition = [drag locationInSpace:_gameContainer];
			self.x = dragPosition.x;
			self.y = dragPosition.y;
		}
	} else if (touchUp) {
        if (!isGrabbed) {
            return;
        }
        SPPoint *touchUpPosition = [touchUp locationInSpace:_gridContainer];
        [self removeEventListener:@selector(dragFromTray:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [_gridContainer addChild:self];
        [_trayContainer removedShip:self];
        self.x = touchUpPosition.x;
        self.y = touchUpPosition.y;
        [self snapToGrid];
        [self addEventListener:@selector(positionShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
		isGrabbed = NO;
	}
}

- (void)positionShip:(SPTouchEvent *)event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
	SPTouch *drag = [[event touchesWithTarget:self andPhase:SPTouchPhaseMoved] anyObject];
	SPTouch *touchUp = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    
    //        SPTouch *touch = touches[0];
    //        SPPoint *movement = [touch movementInSpace:self.parent];
    //
    //        self.x += movement.x;
    //        self.y += movement.y;
    
    if (touch) {
        isGrabbed = YES;
    } else if (drag) {
        if (isGrabbed) {
            SPPoint *dragPosition = [drag locationInSpace:_gridContainer];
            self.x = dragPosition.x;
            self.y = dragPosition.y;
            isDragged = YES;
        }
    } else if (touchUp) {
        if (isDragged) {
            SPPoint *touchUpPosition = [touchUp locationInSpace:_gridContainer];
            [_gridContainer addChild:self];
            self.x = touchUpPosition.x;
            self.y = touchUpPosition.y;
            [self snapToGrid];
            NSLog(@"Height: %f, Width: %f, X: %F, Y: %f", self.height, self.width, self.x, self.y);
            isDragged = NO;
        } else {
            //            [self snapToGrid];
            [self turnRight];
            NSLog(@"should show options");
        }
        isGrabbed = NO;
    }
}


- (void)snapToGrid
{
    // snap to x, y's closest
    int tileSize = _gameContainer.tileSize; // _shipLength
    int k = (_shipLength - (_shipLength % 2)) / 2;
    float l = (1 - (_shipLength % 2)) * tileSize/2;
    
    switch (_dir) {
        case Up:
            _baseColumn = floorf(self.x / tileSize);
            _baseRow = floorf((self.y - l) / tileSize) + k;
            break;
        case Left:
            _baseColumn = floorf((self.x - l) / tileSize) + k;
            _baseRow = floorf(self.y / tileSize);
            break;
        case Down:
            _baseColumn = floorf(self.x / tileSize);
            _baseRow = floorf((self.y + l) / tileSize) - k;
            break;
        case Right:
            _baseColumn = floorf((self.x + l) / tileSize) - k;
            _baseRow = floorf(self.y / tileSize);
        default:
            break;
    }
    [self updateLocation];
}

- (void)updateLocation
{
    float tileSize = _gameContainer.tileSize;
    int k = ((_shipLength - 1) * tileSize)/2;
    if (_dir == Up) {
        self.y = _baseRow * tileSize - k + tileSize/2;
        self.x = _baseColumn * tileSize + tileSize/2;
    } else if (_dir == Right) {
        self.y = _baseRow * tileSize + tileSize/2;
        self.x = _baseColumn * tileSize + k + tileSize/2;
    } else if (_dir == Down) {
        self.y = _baseRow * tileSize + k + tileSize/2;
        self.x = _baseColumn * tileSize + tileSize/2;
    } else if(_dir == Left) {
        self.y = _baseRow * tileSize + tileSize/2;
        self.x = _baseColumn * tileSize - k + tileSize/2;
    }
}

- (void)turnRight
{
    switch (_dir) {
        case Up:
            self.rotation = M_PI/2.0;
            _dir = Right;
            break;
        case Right:
            self.rotation = M_PI;
            _dir = Down;
            break;
        case Down:
            self.rotation = 3 * M_PI/2;
            _dir = Left;
            break;
        case Left:
            self.rotation = 0;
            _dir = Up;
            break;
        default:
            break;
    }
    
    [self updateLocation];
    return;
    
    // Test for collisions
}


- (void)turnLeft
{
    switch (_dir) {
        case Up:
            self.rotation = 3.0f * M_PI/2;
            _dir = Left;
            break;
        case Right:
            self.rotation = 0.0f;
            _dir = Up;
            break;
        case Down:
            self.rotation = M_PI/2;
            _dir = Right;
            break;
        case Left:
            self.rotation = M_PI;
            _dir = Down;
            break;
        default:
            break;
    }
    
    [self updateLocation];
}

- (void)positionedShip
{
    [self removeEventListener:@selector(positionShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self addEventListener:@selector(selectShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

- (void)selectShip:(SPTouchEvent *)event
{
    SPTouch *touchUp = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    if (touchUp) {
        [_gameContainer.shipCommandBar setSelected:self];
    }
}

// Returns the tiles move options for the ship's positions.
- (NSSet *)validMoveTiles
{
    NSMutableSet *validTiles = [[NSMutableSet alloc] init];
    if (_dir == Up) {
        for (NSArray *column in _gameContainer.tiles) {
            for (Tile *tile in column) {
                
                // Up/Down movement
                if (tile.col == _baseColumn) {
                    // Forward
                    if (tile.row <= _baseRow - _shipLength && tile.row > _baseRow - _shipLength - _shipSpeed) {
                        [validTiles addObject:tile];
                    }
                    // Backward
                    if (tile.row == _baseRow + 1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift left
                if (tile.col == _baseColumn - 1) {
                    if (tile.row == _baseRow - _shipLength +1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift right
                if (tile.col == _baseColumn + 1) {
                    if (tile.row == _baseRow - _shipLength +1) {
                        [validTiles addObject:tile];
                    }
                }
            }
        }
    } else if (_dir == Left) {
        for (NSArray *column in _gameContainer.tiles) {
            for (Tile *tile in column) {
                
                // Right/Left movement
                if (tile.row == _baseRow) {
                    // Forward
                    if (tile.col <= _baseColumn - _shipLength && tile.col > _baseColumn - _shipLength - _shipSpeed) {
                        [validTiles addObject:tile];
                    }
                    // Backward
                    if (tile.col == _baseColumn + 1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift up
                if (tile.row == _baseRow - 1) {
                    if (tile.col == _baseColumn - _shipLength +1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift down
                if (tile.row == _baseRow + 1) {
                    if (tile.col == _baseColumn - _shipLength +1) {
                        [validTiles addObject:tile];
                    }
                }
            }
        }
    } else if (_dir == Down) {
        for (NSArray *column in _gameContainer.tiles) {
            for (Tile *tile in column) {
                
                // Up/Down movement
                if (tile.col == _baseColumn) {
                    // Forward
                    if (tile.row >= _baseRow + _shipLength && tile.row < _baseRow + _shipLength + _shipSpeed) {
                        [validTiles addObject:tile];
                    }
                    // Backward
                    if (tile.row == _baseRow - 1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift left
                if (tile.col == _baseColumn - 1) {
                    if (tile.row == _baseRow + _shipLength - 1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift right
                if (tile.col == _baseColumn + 1) {
                    if (tile.row == _baseRow + _shipLength - 1) {
                        [validTiles addObject:tile];
                    }
                }
            }
        }
    } else if (_dir == Right) {
        for (NSArray *column in _gameContainer.tiles) {
            for (Tile *tile in column) {
                
                // Right/Left movement
                if (tile.row == _baseRow) {
                    // Forward
                    if (tile.col >= _baseColumn + _shipLength && tile.col < _baseColumn + _shipLength + _shipSpeed) {
                        [validTiles addObject:tile];
                    }
                    // Backward
                    if (tile.col == _baseColumn - 1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift up
                if (tile.row == _baseRow - 1) {
                    if (tile.col == _baseColumn + _shipLength - 1) {
                        [validTiles addObject:tile];
                    }
                }
                
                // Shift down
                if (tile.row == _baseRow + 1) {
                    if (tile.col == _baseColumn + _shipLength - 1) {
                        [validTiles addObject:tile];
                    }
                }
            }
        }
    }
    return validTiles;
}


#pragma mark("TODO: Check for collision")
- (void)performMoveActionTo:(Tile *)tile
{
    [self move:tile];
}


- (void)move:(Tile *)tile
{
    [self snapToGrid];
    int yChange = 0;
    int xChange = 0;
    if (_dir == Up) {
        int shipBaseRow = _baseRow - _shipLength + 1;
        if (tile.row == _baseRow + 1) {
            shipBaseRow = _baseRow;
        }
        yChange = shipBaseRow - tile.row;
        xChange = _baseColumn - tile.col;
        _baseRow = _baseRow - (shipBaseRow - tile.row);
        _baseColumn = tile.col;
    } else if (_dir == Left) {
        int shipBaseColumn = _baseColumn - _shipLength + 1;
        if (tile.col == _baseColumn + 1) {
            shipBaseColumn = _baseColumn;
        }
        yChange = _baseRow - tile.row;
        xChange = shipBaseColumn - tile.col;
        _baseRow = tile.row;
        _baseColumn = _baseColumn - (shipBaseColumn - tile.col);
    } else if (_dir == Down) {
        int shipBaseRow = _baseRow + _shipLength - 1;
        if (tile.row == _baseRow - 1) {
            shipBaseRow = _baseRow;
        }
        yChange = shipBaseRow - tile.row;
        xChange = _baseColumn - tile.col;
        _baseRow = _baseRow - (shipBaseRow - tile.row);
        _baseColumn = tile.col;
    } else if (_dir == Right) {
        int shipBaseColumn = _baseColumn + _shipLength - 1;
        if (tile.col == _baseColumn - 1) {
            shipBaseColumn = _baseColumn;
        }
        yChange = _baseRow - tile.row;
        xChange = shipBaseColumn - tile.col;
        _baseRow = tile.row;
        _baseColumn = _baseColumn - (shipBaseColumn - tile.col);
    }
    int tileSize = _gameContainer.tileSize;
    SPTween *tween = [SPTween tweenWithTarget:self time:0.5 transition:SP_TRANSITION_LINEAR];
    [tween animateProperty:@"y" targetValue:self.y - yChange * tileSize];
    [tween animateProperty:@"x" targetValue:self.x - xChange * tileSize];
    [_gameContainer.shipJuggler addObject:tween];
}

@end