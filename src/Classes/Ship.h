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
	Base_Type
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
- (void)setSurroundingTilesVisible;

- (NSSet *)validMoveTiles;
- (NSSet *)validDropMineTiles;
- (NSSet *)validShootCannonTiles;
- (void)updateLocation;
- (void)performMoveActionTo:(Tile *)tile;
- (NSArray *)rotateTileList:(Direction) newdir;

@property (nonatomic, assign) ShipType shipType;
@property (nonatomic, assign) Direction dir;
@property (nonatomic, assign) int baseRow;
@property (nonatomic, assign) int baseColumn;
@property (nonatomic, strong) NSArray *shipWeapons;


@property (nonatomic, assign) BOOL isEnemyShip;

- (void)hitByCannon;
@property (nonatomic, assign) int health; // integer ==> destroyed = 0, damaged = 1, intact = 2.

@property (nonatomic, strong) NSMutableArray *shipSegments;
- (void)updateTilesOccupied;

@end
