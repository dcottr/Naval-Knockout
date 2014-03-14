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

@property (nonatomic, assign) int shipLength;
@property (nonatomic, assign) int shipSpeed;
@property (nonatomic, assign) ArmourType shipArmour;

@property (nonatomic, strong) Tile *tilesOccupied; // base of ship tile the ship is sitting on.


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
        shipLengthMap = @{num(Cruiser): num(5), num(Destroyer): num(4), num(Torpedo): num(3), num(Miner): num(2), num(Radar): num(3)};
        shipSpeedMap = @{num(Cruiser): num(10), num(Destroyer): num(8), num(Torpedo): num(9), num(Miner): num(6), num(Radar): num(3)};
        shipArmourMap = @{num(Cruiser): num(ArmourHeavy), num(Destroyer): num(ArmourNormal), num(Torpedo): num(ArmourNormal), num(Miner): num(ArmourHeavy), num(Radar): num(ArmourNormal)};
        shipWeaponsMap = @{num(Cruiser): @[num(WeaponHeavyCannon)], num(Destroyer): @[num(WeaponCannon), num(WeaponTorpedo)], num(Torpedo): @[num(WeaponCannon), num(WeaponTorpedo)], num(Miner): @[num(WeaponCannon), num(WeaponMine)], num(Radar): @[num(WeaponCannon)]};
        shipTypeMapsInitialized = YES;
		shipRadarDimensions =@{num(Cruiser): @[num(3),num(10)], num(Destroyer):@[num(3),num(8)], num(Torpedo):@[num(3),num(6)], num(Miner):@[num(6),num(5)] , num(Radar):@[num(6),num(3)]};
		shipCannonDimensions = @{num(Cruiser): @[num(11), num(15), num(5)], num(Destroyer):@[num(9),num(12),num(4)], num(Torpedo):@[num(5),num(5), num(0)], num(Miner):@[num(5),num(4),num(1)], num(Radar):@[num(3),num(5),num(1)]};
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
        _health = 2;
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
    NSLog(@"Updating location at row: %d", _baseRow);
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
    if (_tilesOccupied) {
        _tilesOccupied.myShip = nil;
        [_tilesOccupied setClear];
    }
    
    for (NSArray *column in _gameContainer.tiles) {
        for (Tile *tile in column) {
            if (tile.col == _baseColumn && tile.row == _baseRow) {
                _tilesOccupied = tile;
                tile.myShip = self;
                NSLog(@"At row: %d, col: %d, life: %d", tile.row, tile.col, _health);
                if (_health == 0) {
                    [tile setDestroyed];
                } else if (_health == 1) {
                    [tile setDamaged];
                }
            }
        }
    }
}


- (void)hitByCannon
{
    if (_health == 2) {
        if (_shipArmour == ArmourHeavy) {
            _health = 1;
            [self updateTilesOccupied];
            return;
        }
    }
    
    NSLog(@"Hit by cannon, new health: %d", _health);
    _health = 0;
    [self updateTilesOccupied];
    return;
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
    if (!_isEnemyShip) {
        [self setSurroundingTilesVisible];
    }
    return;
    
    // Test for collisions
}

- (void)setHealth:(int)health
{
    if (health == 0) {
        _shipSpeed = ([[shipSpeedMap objectForKey:num(_shipType)] intValue] *(_shipLength - 1) / _shipLength);
    } else {
        _shipSpeed = [[shipSpeedMap objectForKey:num(_shipType)] intValue];
    }
    _health = health;
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
    int length  = [[radarSize objectAtIndex:1] intValue]; // length is long side
    NSLog(@"semiwidth : %d , length : %d", semiwidth, length);
    [[[_gameContainer.tiles objectAtIndex:_baseColumn] objectAtIndex:_baseRow] fogOfWar:YES];
    switch (_dir) {
        case Down:  // swap length + width
            for ( int i = _baseRow +1; i <= _baseRow +1 + length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = _baseColumn - semiwidth; j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i];
                    [t fogOfWar:YES];
                    //		  t.visible =YES;
                }
            }
            break;
            
        case Up: // swap l + w, face downward
            for ( int i = _baseRow - 1; i >= _baseRow -1 - length && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = _baseColumn - semiwidth; j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i];
                    [t fogOfWar:YES];
                    //		  t.visible =YES;
                }
            }
            break;
            
        case Left:
            for ( int i = _baseColumn	-1; i >= _baseColumn -1 - length && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = _baseRow - semiwidth; j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j];
                    [t fogOfWar:YES];
                    //		  t.visible =YES;
                }
            }
            break;
            
        default:  // object is facing right
            for ( int i = _baseColumn	+1; i <= _baseColumn +1 + length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = _baseRow - semiwidth; j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    Tile *t= [[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j];
                    [t fogOfWar:YES];
                    //		  t.visible =YES;
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
    // unfortunately obj-c doesn't do factory well so we repeat a lot of logic
    
    switch (_dir) {
        case Down:  // swap length + width
            for ( int i = _baseRow -offset; i <= _baseRow -offset + length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = _baseColumn - semiwidth; j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject:[[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i]];
                }
            }
            break;
            
        case Up: // swap l + w, face downward
            for ( int i = _baseRow +offset; i >= _baseRow +offset - length  && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = _baseColumn - semiwidth; j<= semiwidth + _baseColumn && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject: [[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i]];
                    
                }
            }
            break;
            
        case Left:
            for ( int i = _baseColumn	+ offset; i >= _baseColumn +offset- length && i<_gameContainer.tileCount && i>=0; i--){
                for ( int j = _baseRow - semiwidth; j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
                    [validTiles addObject: [[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
                    
                }
            }
            break;
            
        default:  // object is facing right
            for ( int i = _baseColumn	-offset; i <= _baseColumn -offset+ length && i<_gameContainer.tileCount && i>=0; i++){
                for ( int j = _baseRow - semiwidth; j<= semiwidth + _baseRow && j<_gameContainer.tileCount && j>=0; j++ ){
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
  int length = [[shipLengthMap objectForKey:num(_shipType)] intValue];
 
	 // Upper Left
	if( (_dir == Left && newdir == Up) || (_dir == Up && newdir == Left) ){
	  int k =1;
	  for(int j= _baseRow; j<=_baseRow + length; j++){
		for(int i = _baseColumn - length +k; i <= _baseColumn; i++){
		  @try{
			[tiles addObject:[[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i]];
		  }
		  @catch (NSException *e){
			NSLog(@"you tried to rotate from row %d", _baseRow );
			return nil; // tried to rotate through edge of map: no dice
		  }
		}
		k++;
	  }
	  if (_dir == Up) // send the reverse of what we just calculated
	  {
		return [[tiles reverseObjectEnumerator] allObjects];
	  }
	}
  
  // Upper right
  if ( (_dir == Up && newdir == Right) || (_dir == Right && newdir == Up)){
	int k =1;
	for(int i = _baseColumn; i<=_baseColumn +length -1; i++){
	  for (int j= _baseRow + length -k; j>=_baseRow; j--){
		@try{
		  [tiles addObject:[[_gameContainer.tiles objectAtIndex:j] objectAtIndex:i]];
		  
		}
		@catch (NSException *e){
		  NSLog(@"you tried to rotate from column %d", _baseColumn );
		  return nil;
		}
	  }
	  k++;
	}
	if (_dir == Right) // send the reverse of what we just calculated
	{
	  return [[tiles reverseObjectEnumerator] allObjects];
	}
  }
  
  // Lower Right
  
  if ( (_dir == Right && newdir == Down) || (_dir == Down && newdir == Right)){
	int k =0;
	for(int i = _baseRow ; i>_baseRow-length; i--){
	  for (int j= _baseColumn; j<=_baseColumn + length - k; j++ ){
		@try{
		  [tiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
		}
		@catch (NSException *e){
		  NSLog(@"you tried to rotate from  %d", _baseColumn );
		  return nil;
		}
	  }
	  k++;
	}
	if (_dir == Down) // send the reverse of what we just calculated
	{
	  return [[tiles reverseObjectEnumerator] allObjects];
	}
  }
  
  // Lower left
  
  if( (_dir == Down && newdir == Left) || (_dir == Left && newdir == Down) ){
	int k = 0;
	for(int i = _baseRow - length +1; i <= _baseRow; i++){
	  for(int j= _baseColumn; j<=_baseColumn -k; j-- ){
		@try{
		  [tiles addObject:[[_gameContainer.tiles objectAtIndex:i] objectAtIndex:j]];
		}
		@catch (NSException *e){
		  NSLog(@"you tried to rotate from row %d", _baseRow );
		  return nil; // tried to rotate through edge of map: no dice
		}
	  }
	  k++;
	}
	if (_dir == Left) // send the reverse of what we just calculated
	{
	  return [[tiles reverseObjectEnumerator] allObjects];
	}
  }
  
	 
  return tiles;
  
}



@end
