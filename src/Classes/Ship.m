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
#import "ShipSegment.h"

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

@property (nonatomic, assign) int shipLength;
@property (nonatomic, assign) int shipSpeed;

@end

static SPTexture *shipTexture = nil;
static NSDictionary *shipLengthMap = nil;
static NSDictionary *shipSpeedMap = nil;
static NSDictionary *shipArmourMap = nil;
static NSDictionary *shipWeaponsMap = nil;
static NSDictionary *shipRadarDimensions =  nil;
static NSDictionary *shipCannonDimensions = nil;
static BOOL shipTypeMapsInitialized = NO;


@implementation Ship

+ (void)initShipTypeMaps
{
    if (!shipTypeMapsInitialized) {
        shipLengthMap = @{num(Cruiser): num(5), num(Destroyer): num(4), num(Torpedo): num(3), num(Miner): num(2), num(Radar): num(3), num(BaseType): num(10)};
        shipSpeedMap = @{num(Cruiser): num(10), num(Destroyer): num(8), num(Torpedo): num(9), num(Miner): num(6), num(Radar): num(3), num(BaseType):num(0)};
        shipArmourMap = @{num(Cruiser): num(ArmourHeavy), num(Destroyer): num(ArmourNormal), num(Torpedo): num(ArmourNormal), num(Miner): num(ArmourHeavy), num(Radar): num(ArmourNormal), num(BaseType):num(ArmourNormal)};
        shipWeaponsMap = @{num(Cruiser): @[num(WeaponHeavyCannon)], num(Destroyer): @[num(WeaponCannon), num(WeaponTorpedo)], num(Torpedo): @[num(WeaponCannon), num(WeaponTorpedo)], num(Miner): @[num(WeaponCannon), num(WeaponMine)], num(Radar): @[num(WeaponCannon)], num(BaseType):@[]};
        
        // width, length, back.
        shipRadarDimensions =@{num(Cruiser): @[num(3),num(10), num(0)], num(Destroyer):@[num(3),num(8), num(0)], num(Torpedo):@[num(3),num(6), num(0)], num(Miner):@[num(5),num(3), num(3)] , num(Radar):@[num(3),num(6), num(0)], num(BaseType):@[num(3),num(10),num(2)]};
        shipCannonDimensions = @{num(Cruiser): @[num(11), num(15), num(5)], num(Destroyer):@[num(9),num(12),num(4)], num(Torpedo):@[num(5),num(5), num(0)], num(Miner):@[num(5),num(4),num(1)], num(Radar):@[num(3),num(5),num(1)], num(BaseType):@[]};
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
        self.width = 32;
        self.height = 32 * _shipLength;
        
        _dir = Up;
        [self addChild:_shipImage];
        _shipImage.alpha = 0.0f;
        
        NSMutableArray *shipSegments = [[NSMutableArray alloc] init];
        for (int i = 0; i < _shipLength; i++) {
            
            ShipSegmentIndex segIndex;
            if (i == 0) {
                segIndex = ShipSegmentIndexBack;
            } else if (i == _shipLength - 1) {
                segIndex = ShipSegmentIndexFront;
            } else {
                segIndex = ShipSegmentIndexMid;
            }
            
            ShipSegment *shipSegment = [[ShipSegment alloc] initWithIndex:segIndex ship:self];
            [shipSegments addObject:shipSegment];
            shipSegment.width = 32;
            shipSegment.height = 32;
            [self addChild:shipSegment];
            shipSegment.x = 0;
            shipSegment.y = (_shipLength - 1 - i) * 32;
        }
        _shipSegments = shipSegments;
        
        
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
        self.rotation = 0;
        self.y = _baseRow * tileSize - k + tileSize/2;
        self.x = _baseColumn * tileSize + tileSize/2;
    } else if (_dir == Right) {
        self.rotation = M_PI/2;
        self.y = _baseRow * tileSize + tileSize/2;
        self.x = _baseColumn * tileSize + k + tileSize/2;
    } else if (_dir == Down) {
        self.rotation = M_PI;
        self.y = _baseRow * tileSize + k + tileSize/2;
        self.x = _baseColumn * tileSize + tileSize/2;
    } else if(_dir == Left) {
        self.rotation = 3 * M_PI/2;
        self.y = _baseRow * tileSize + tileSize/2;
        self.x = _baseColumn * tileSize - k + tileSize/2;
    }
    if (!_isEnemyShip) {
        [self setSurroundingTilesVisible];
    }
    [self updateTilesOccupied];
}

- (void)updateTilesOccupied
{
    for (NSArray *column in _gameContainer.tiles) {
        for (Tile *tile in column) {
            if (_dir == Up) {
                
                if (tile.col == _baseColumn) {
                    if (tile.row <= _baseRow && tile.row > _baseRow - _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:( (_baseRow - tile.row))];
                        segment.tile = tile;
                        tile.myShip = self;
                        tile.myShipSegment = segment;
                    }
                }
            } else if(_dir == Left) {
                if (tile.row == _baseRow) {
                    if (tile.col <= _baseColumn && tile.col > _baseColumn - _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:((_baseColumn - tile.col))];
                        segment.tile = tile;
                        tile.myShip = self;
                        tile.myShipSegment = segment;
                    }
                }
            } else if(_dir == Right) {
                if (tile.row == _baseRow) {
                    if (tile.col >= _baseColumn && tile.col < _baseColumn + _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:(tile.col - _baseColumn)];
                        segment.tile = tile;
                        tile.myShip = self;
                        tile.myShipSegment = segment;
                    }
                }
            } else if(_dir == Down) {
                if (tile.col == _baseColumn) {
                    if (tile.row >= _baseRow && tile.row < _baseRow + _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:(tile.row - _baseRow)];
                        segment.tile = tile;
                        tile.myShip = self;
                        tile.myShipSegment = segment;
                    }
                }
            }
        }
    }
    // TODO, delete health attribute in ship (put it in segments)
    
    for (ShipSegment *segment in _shipSegments) {
        [segment updateSegmentDamage];
    }
    [self updateSpeed];
}

- (void)sinkShip
{
    _isSunk = YES;
    for (NSArray *column in _gameContainer.tiles) {
        for (Tile *tile in column) {
            if (_dir == Up) {
                if (tile.col == _baseColumn) {
                    if (tile.row <= _baseRow && tile.row > _baseRow - _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:( (_baseRow - tile.row))];
                        segment.tile = tile;
                        if (segment.tile.myShipSegment == segment) {
                            tile.myShip = nil;
                            tile.myShipSegment = nil;
                        }
                    }
                }
            } else if(_dir == Left) {
                if (tile.row == _baseRow) {
                    if (tile.col <= _baseColumn && tile.col > _baseColumn - _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:((_baseColumn - tile.col))];
                        segment.tile = tile;
                        if (segment.tile.myShipSegment == segment) {
                            tile.myShip = nil;
                            tile.myShipSegment = nil;
                        }
                    }
                }
            } else if(_dir == Right) {
                if (tile.row == _baseRow) {
                    if (tile.col >= _baseColumn && tile.col < _baseColumn + _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:(tile.col - _baseColumn)];
                        segment.tile = tile;
                        if (segment.tile.myShipSegment == segment) {
                            tile.myShip = nil;
                            tile.myShipSegment = nil;
                        }
                    }
                }
            } else if(_dir == Down) {
                if (tile.col == _baseColumn) {
                    if (tile.row >= _baseRow && tile.row < _baseRow + _shipLength) {
                        ShipSegment *segment = [_shipSegments objectAtIndex:(tile.row - _baseRow)];
                        segment.tile = tile;
                        if (segment.tile.myShipSegment == segment) {
                            tile.myShip = nil;
                            tile.myShipSegment = nil;
                        }
                    }
                }
            }
        }
    }
    for (ShipSegment *segment in _shipSegments) {
        NSLog(@"Sink segment");
        [segment.tile setSunk];
    }
}


- (void)updateSpeed
{
    int liveSegmentCount = 0;
    int originalSpeed = [[shipSpeedMap objectForKey:num(_shipType)] intValue];
    for (ShipSegment *segment in _shipSegments) {
        if (segment.health > 0) {
            liveSegmentCount++;
        }
    }
    _shipSpeed = liveSegmentCount * (int)(originalSpeed/_shipLength);
}

- (void)turnRight
{
	Direction tempdir = _dir;
    float temprotation;
    switch (tempdir) {
        case Up:
            temprotation = M_PI/2.0;
            tempdir = Right;
            break;
        case Right:
            temprotation = M_PI;
            tempdir = Down;
            break;
        case Down:
            temprotation = 3 * M_PI/2;
            tempdir= Left;
            break;
        case Left:
            temprotation = 0;
            tempdir = Up;
            break;
        default:
            break;
    }
    self.rotation = temprotation;
    _dir = tempdir;
    [self updateLocation];
    if (!_isEnemyShip) {
        [self setSurroundingTilesVisible];
    }
}

- (void)turnLeft
{
    Direction tempdir  = _dir;
    float temprotation;
    switch (tempdir) {
            
        case Up:
            temprotation = 3.0f * M_PI/2;
            tempdir= Left;
            break;
        case Right:
            temprotation = 0.0f;
            tempdir= Up;
            break;
        case Down:
            temprotation = M_PI/2;
            tempdir = Right;
            break;
        case Left:
            temprotation = M_PI;
            tempdir= Down;
            break;
        default:
            break;
    }
	self.rotation = temprotation;
	_dir = tempdir;
	[self updateLocation];
	if (!_isEnemyShip) {
        [self setSurroundingTilesVisible];
	}
}

- (void)positionedShip
{
    [self removeEventListener:@selector(dragFromTray:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self removeEventListener:@selector(positionShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self addEventListener:@selector(selectShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

- (void)swapPositionWithShip:(Ship *)ship
{
    int tempBaseCol = ship.baseColumn;
    int tempBaseRow = ship.baseRow;
    ship.baseColumn = _baseColumn;
    ship.baseRow = _baseRow;
    _baseColumn = tempBaseCol;
    _baseRow = tempBaseRow;
    [ship updateLocation];
    [self updateLocation];
}

- (void)selectShip:(SPTouchEvent *)event
{
    SPTouch *touchUp;
    for (SPTouch *touch in [event touches]) {
        if (touch.phase == SPTouchPhaseEnded) {
            touchUp = touch;
            break;
        }
    }
    
    if (touchUp && _gameContainer.myTurn) {
        if (self.shipType == BaseType) {
            return;
        }
        
        if (_gameContainer.currentStateType == StateTypePlay) {
            [_gameContainer.shipCommandBar setSelected:self];
        } else if ((_gameContainer.currentStateType == StateTypeShipSetupRight || _gameContainer.currentStateType == StateTypeShipSetupLeft)) {
            if (_gameContainer.shipCommandBar.ship == nil) {
                [_gameContainer.shipCommandBar setSelected:self];
            } else {
                [self swapPositionWithShip:_gameContainer.shipCommandBar.ship];
            }
        }
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

- (NSSet *)validDropMineTiles
{
    NSMutableSet *validTiles = [[NSMutableSet alloc] init];
    for (NSArray *column in _gameContainer.tiles) {
        for (Tile *tile in column) {
            if (_dir == Up) {
                if (tile.col == _baseColumn + 1 || tile.col == _baseColumn - 1) {
                    if (tile.row == _baseRow || tile.row == _baseRow - 1) {
                        [validTiles addObject:tile];
                    }
                } else if (tile.col == _baseColumn) {
                    if (tile.row == _baseRow + 1 || tile.row == _baseRow - 2) {
                        [validTiles addObject:tile];
                    }
                }
            } else if (_dir == Down) {
                if (tile.col == _baseColumn + 1 || tile.col == _baseColumn - 1) {
                    if (tile.row == _baseRow || tile.row == _baseRow + 1) {
                        [validTiles addObject:tile];
                    }
                } else if (tile.col == _baseColumn) {
                    if (tile.row == _baseRow + 2 || tile.row == _baseRow - 1) {
                        [validTiles addObject:tile];
                    }
                }
            } else if (_dir == Left) {
                if (tile.row == _baseRow + 1 || tile.row == _baseRow - 1) {
                    if (tile.col == _baseColumn || tile.col == _baseColumn - 1) {
                        [validTiles addObject:tile];
                    }
                } else if (tile.row == _baseRow) {
                    if (tile.col == _baseColumn + 1 || tile.col == _baseColumn - 2) {
                        [validTiles addObject:tile];
                    }
                }
            } else if (_dir == Right) {
                if (tile.row == _baseRow + 1 || tile.row == _baseRow - 1) {
                    if (tile.col == _baseColumn || tile.col == _baseColumn + 1) {
                        [validTiles addObject:tile];
                    }
                } else if (tile.row == _baseRow) {
                    if (tile.col == _baseColumn + 2 || tile.col == _baseColumn - 1) {
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
    /*
     Tile *destination;
     NSMutableArray *tileList = [[NSMutableArray alloc] init];
     if( tile.col > _baseRow){ // move north
     for (int i = _baseRow+1; i<tile.col; i ++){
     [tilelist addObject:[_gameContainer.tile objectAtIndex:i] objectAtIndex: ]
     }
     }
     */
    
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
    if (!_isEnemyShip) {
        [self setSurroundingTilesVisible];
    }
    [self updateTilesOccupied];
}

- (void)setIsEnemyShip:(BOOL)isEnemyShip
{
    _isEnemyShip = isEnemyShip;
    if (isEnemyShip) {
        [self removeEventListener:@selector(dragFromTray:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [self removeEventListener:@selector(positionShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
        [self removeEventListener:@selector(selectShip:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    }
}


-(void)setSurroundingTilesVisible
{
    // get values for length + width of ship type
    NSArray *radarSize = [shipRadarDimensions objectForKey:num(_shipType)];
    // do cases on directions to get tiles of radar range
    int semiwidth =  ([[radarSize objectAtIndex:0] intValue] - 1)/2; // half the width ; is odd so -1
    int length  = [[radarSize objectAtIndex:1] intValue] - 1; // length is long side
    int offset = [[radarSize objectAtIndex:2] intValue];
    [[[_gameContainer.tiles objectAtIndex:_baseColumn] objectAtIndex:_baseRow] fogOfWar:YES];
    switch (_dir) {
        case Down:  // swap length + width
            for ( int i = MAX(_baseRow +1 -  offset, 0); i <= _baseRow +1 + length && i<_gameContainer.tileCount && i>=0; i++){
                for (int j = MAX(0, _baseColumn - semiwidth); j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i];
                    [t fogOfWar:YES];
                }
            }
            break;
            
        case Up: // swap l + w, face downward
            for ( int i = MAX(_baseRow - 1 + offset, 0); i >= _baseRow -1 - length && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = MAX(0, _baseColumn - semiwidth); j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i];
                    [t fogOfWar:YES];
                }
            }
            break;
            
        case Left:
            for ( int i = MAX(_baseColumn-1+offset, 0); i >= _baseColumn -1 - length && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = MAX(_baseRow - semiwidth, 0); j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j];
                    [t fogOfWar:YES];
                }
            }
            break;
            
        default:  // object is facing right
            for ( int i = MAX(_baseColumn + 1 - offset, 0); i <= _baseColumn +1 + length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = MAX(_baseRow - semiwidth, 0); j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j];
                    [t fogOfWar:YES];
                }
            }
            break;
    }
}


- (NSSet *)validShootCannonTiles
{
    NSMutableSet *validTiles = [[NSMutableSet alloc] init];
    
    NSArray *cannonSize = [shipCannonDimensions objectForKey:num(_shipType)];
    int semiwidth =  ([[cannonSize objectAtIndex:0] intValue] - 1)/2; // half the width
    int length  = [[cannonSize objectAtIndex:1] intValue]; // length is long side
    int offset = [[cannonSize objectAtIndex:2] intValue];
    switch (_dir) {
        case Down:  // swap length + width
            for ( int i = MAX(_baseRow-offset,0); i < _baseRow -offset + length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = MAX(_baseColumn - semiwidth, 0); j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject:[[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i]];
                }
            }
            break;
            
        case Up: // swap l + w, face downward
            for ( int i = _baseRow +offset; i > _baseRow +offset - length  && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = MAX(_baseColumn - semiwidth, 0); j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject: [[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i]];
                    
                }
            }
            break;
            
        case Left:
            for ( int i = _baseColumn	+ offset; i > _baseColumn +offset- length && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = MAX(_baseRow - semiwidth, 0); j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject: [[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
                    
                }
            }
            break;
            
        default:  // object is facing right
            for ( int i = MAX(_baseColumn - offset, 0); i < _baseColumn -offset+ length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = MAX(_baseRow - semiwidth, 0); j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
                }
            }
            break;
    }
    
	
    /*  original code for destroyers
     for (NSArray *column in _gameContainer.tiles) {
     for (Tile *tile in column) {
     if (_dir == Up ) {
     if (tile.row >= _baseRow - 7 && tile.row <= _baseRow + 4) {
     if (tile.col >= _baseColumn - 4 && tile.col <= _baseColumn + 4) {
     [validTiles addObject:tile];
     }
     }
     } else if (_dir == Down) {
     if (tile.row >= _baseRow - 4 && tile.row <= _baseRow + 7) {
     if (tile.col >= _baseColumn - 4 && tile.col <= _baseColumn + 4) {
     [validTiles addObject:tile];
     }
     }
     } else if (_dir == Left) {
     if (tile.col >= _baseColumn - 7 && tile.col <= _baseColumn + 4) {
     if (tile.row >= _baseRow - 4 && tile.row <= _baseRow + 4) {
     [validTiles addObject:tile];
     }
     }
     } else if (_dir == Right) {
     if (tile.col >= _baseColumn - 4 && tile.col <= _baseColumn + 7) {
     if (tile.row >= _baseRow - 4 && tile.row <= _baseRow + 4) {
     [validTiles addObject:tile];
     }
     }
     }
     }
     }
     */
    return validTiles;
}

-(NSArray *)rotateTileList:(Direction)newdir
{
    NSMutableArray *tiles =[[NSMutableArray alloc] init];
    //	int length = [[shipLengthMap objectForKey:num(_shipType)] intValue];
	// x coordinate of tile that isn't touched during rotation
    // Upper Left
	if( (_dir == Left && newdir == Up) || (_dir == Up && newdir == Left) ){
	  //  get entire rectangle and clear out
	  int upperbound = _baseRow-_shipLength + 1;
	  int leftbound  = _baseColumn - _shipLength +1;
	  int indent = 0;
	  if (upperbound >= 0 && leftbound >= 0){
		for (int i=_baseRow; i>= upperbound; i--){
		  if (i < _baseRow -1){
			indent++;
		  }
		  for ( int j = _baseColumn; j >= leftbound + indent; j--){
			[tiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
		  }
		}
	  }
	  else {
		 // attempted rotation is out of bounds
#pragma message("handle rotation failure outside of this method")
		return nil;
	  }
	  if (_dir == Up)
	  {
	  // send the reverse of what we just calculated so that we collide with closer tiles first
            return [[tiles reverseObjectEnumerator] allObjects];
	  }
	}
    
    // Upper right
    if( (_dir == Up && newdir == Right) || (_dir == Right && newdir == Up) ){
	  int upperbound = _baseRow-_shipLength + 1;
	  int rightbound = _baseColumn + _shipLength - 1;
	  int indent = 0;
	  if (upperbound >= 0 && rightbound < 30){
		for (int i=_baseRow; i>= upperbound; i--){
		  if ( i < _baseRow -1){
			indent++;
		  }
		  for(int j = _baseColumn; j <= rightbound - indent; j++){
			
			[tiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
		  }
		  
		}
	  }
	  
        if (_dir == Right) // send the reverse of what we just calculated
        {
            return [[tiles reverseObjectEnumerator] allObjects];
        }
    }
    
    // Lower Right
    
    if ( (_dir == Right && newdir == Down) || (_dir == Down && newdir == Right)){
	  int lowerbound = _baseRow + _shipLength - 1;
	  int rightbound = _baseColumn + _shipLength - 1;
	  int indent = 0;
	  if( lowerbound <= 30 && rightbound >=0 ){
		for (int i = _baseRow; i <= lowerbound; i++){
		  if (i > _baseRow + 1){
			indent++;
		  }
		  for(int j = _baseColumn; j<=rightbound-indent; j ++ ){
			[tiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
		  }
		}
	  }
	  else {
		return nil;
	  }
	  
	  if (_dir == Down) // send the reverse of what we just calculated
        {
            return [[tiles reverseObjectEnumerator] allObjects];
        }
    }
    
    // Lower left
    
    if( (_dir == Down && newdir == Left) || (_dir == Left && newdir == Down) ){
	  int lowerbound = _baseColumn + _shipLength - 1;
	  int leftbound = _baseColumn - _shipLength + 1;
	  int indent = 0;
	  if ( lowerbound<= 30 && leftbound>=0){
		for (int i = _baseRow; i<= lowerbound; i++){ // top to bottom
		  if (i >= _baseRow + 1){
			indent++;
		  }
		  for(int j = _baseColumn; j>=leftbound+indent; j--){
			[tiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
		  }
		}
	  }
	  else{
		return nil;
	  }
	  if (_dir == Left) // send the reverse of what we just calculated
        {
            return [[tiles reverseObjectEnumerator] allObjects];
        }
    }
    
    
    return tiles;
    
}

-(Tile *)shouldMove:(NSArray *)tileList
{
    if(tileList){
        for (Tile *t in tileList){
            if (t.reef){
                NSLog(@"you hit a reef at %d : %d", t.row,t.col);
                [t notifyEvent];
                return t;
            }
        }
    }
    return nil;
}



@end
