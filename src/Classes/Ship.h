//
//  Ship.h
//  Scaffold
//
//  Created by David Cottrell on 2014-03-02.
//
//

#import "SPSprite.h"


enum {
    Up,
    Right,
    Down,
    Left
};
typedef NSInteger Direction;

enum {
    Cruiser,
    Destroyer,
    Torpedo,
    Miner,
    Radar,
	BaseType
};
typedef NSInteger ShipType;

enum {
    ArmourHeavy,
    ArmourNormal
};
typedef NSInteger ArmourType;

enum {
    WeaponHeavyCannon,
    WeaponCannon,
    WeaponTorpedo,
    WeaponMine
};
typedef NSInteger WeaponType;


@class Game, Tile;
@interface Ship : SPSprite

- (id)initWithGame:(Game *)game type:(ShipType)type;
- (void)positionedShip;

- (void)turnRight;
- (void)turnLeft;
- (void)spin;
- (void)setSurroundingTilesVisible;

- (NSSet *)validMoveTiles;
- (NSSet *)validDropMineTiles;
- (NSSet *)validShootCannonTiles;
- (void)toggleSuperRadar:(BOOL)on;
- (void)updateLocation;
- (void)performMoveActionTo:(Tile *)tile;
- (NSArray *)rotateTileList:(Direction) newdir;
- (void)sinkShip;

@property (nonatomic, assign) ShipType shipType;
@property (nonatomic, assign) ArmourType shipArmour;
@property (nonatomic, assign) Direction dir;
@property (nonatomic, assign) int baseRow;
@property (nonatomic, assign) int baseColumn;
@property (nonatomic, assign) BOOL isSunk;
@property (nonatomic, assign) BOOL movementIsDisabled;
@property (nonatomic, strong) NSArray *shipWeapons;

@property (nonatomic, assign) BOOL isEnemyShip;

@property (nonatomic, strong) NSMutableArray *shipSegments;
- (void)updateTilesOccupied;

- (BOOL)isTouchingBase;

@end
