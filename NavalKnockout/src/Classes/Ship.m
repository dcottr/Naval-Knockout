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

//- (void)move:(Tile *)tile
//{
//    tile.row * 32 + _gameContainer.tileSize/2;
//    SPTween *tween = [SPTween tweenWithTarget:self time:0.5 transition:SP_TRANSITION_LINEAR];
//    [tween animateProperty:@"y" targetValue:self.y - ]
//}

// Move up on tap.
- (void) move:(SPTouchEvent *)event
{
    SPTouch *touch = [[event touchesWithTarget:self andPhase:SPTouchPhaseBegan] anyObject];
    SPDisplayObject *ship = (SPDisplayObject *)event.target;
    if (touch) {
        SPTween *f = [SPTween tweenWithTarget:ship time:0.5 transition:SP_TRANSITION_LINEAR];
        [f animateProperty:@"y" targetValue:ship.y - 60];
        [_gameContainer.shipJuggler addObject:f];
    }
}

- (void)snapToGrid
{
    // snap to x, y's closest
    int tileSize = _gameContainer.tileSize; // _shipLength
    if (_dir == Up || _dir == Down) {
        if (_shipLength%2 == 0) {
            self.x = floorf(self.x / tileSize) * tileSize + tileSize/2.0f;
            self.y = round(self.y / tileSize) * tileSize;
        } else {
            self.x = floorf(self.x / tileSize) * tileSize + tileSize/2.0f;
            self.y = floorf(self.y / tileSize) * tileSize + tileSize/2.0f;
        }
    } else {
        if (_shipLength%2 == 0) {
            self.y = floorf(self.y / tileSize) * tileSize + tileSize/2.0f;
            self.x = round(self.x / tileSize) * tileSize;
        } else {
            self.y = floorf(self.y / tileSize) * tileSize + tileSize/2.0f;
            self.x = floorf(self.x / tileSize) * tileSize + tileSize/2.0f;
            
        }
    }
    NSLog(@"x: %f, y: %f", self.x, self.y);
}

- (void)turnRight
{
    // Test for collisions
    int k = ((_shipLength - 1) * _gameContainer.tileSize)/2;
    float newX;
    float newY;
    
    switch (_dir) {
        case Up:
            newX = self.x + k;
            newY = self.y + k;
            self.rotation = M_PI/2.0;
            _dir = Right;
            break;
        case Right:
            newX = self.x - k;
            newY = self.y + k;
            self.rotation = M_PI;
            _dir = Down;
            break;
        case Down:
            newX = self.x - k;
            newY = self.y - k;
            self.rotation = 3 * M_PI/2;
            _dir = Left;
            break;
        case Left:
            newX = self.x + k;
            newY = self.y - k;
            self.rotation = 0;
            _dir = Up;
            break;
        default:
            break;
    }
    
    self.x = newX;
    self.y = newY;
}


- (void)turnLeft
{
    int k = ((_shipLength - 1) * _gameContainer.tileSize)/2;
    float newX;
    float newY;
    
    switch (_dir) {
        case Up:
            newX = self.x - k;
            newY = self.y + k;
            self.rotation = 3.0f * M_PI/2;
            _dir = Left;
            break;
        case Right:
            newX = self.x - k;
            newY = self.y - k;
            self.rotation = 0.0f;
            _dir = Up;
            break;
        case Down:
            newX = self.x + k;
            newY = self.y - k;
            self.rotation = M_PI/2;
            _dir = Right;
            break;
        case Left:
            newX = self.x + k;
            newY = self.y + k;
            self.rotation = M_PI;
            _dir = Down;
            break;
        default:
            break;
    }
    
    self.x = newX;
    self.y = newY;
}

- (void)setX:(float)x
{
    [super setX:x];
    [self updatePosition];
}

- (void)setY:(float)y
{
    [super setY:y];
    [self updatePosition];
}


// Updates _baseColumn and _baseRow
- (void)updatePosition
{
    int tileSize = _gameContainer.tileSize;
    switch (_dir) {
        case Up:
            _baseColumn = floor(self.x / tileSize);
            _baseRow = floor((self.y / tileSize)) + _shipLength % 2;
            break;
            
        default:
            break;
    }
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

- (NSSet *)validMoveTiles
{
    NSMutableSet *validTiles = [[NSMutableSet alloc] init];
    if (_dir == Up) {
        NSArray *column = [_gameContainer.tiles objectAtIndex:_baseColumn];
        for (Tile *tile in column) {
            if (tile.row <= _baseRow - _shipLength) {
                [validTiles addObject:tile];
                NSLog(@"col: %d row: %d", tile.col, tile.row);
            }
        }
    }
    return validTiles;
}


@end
