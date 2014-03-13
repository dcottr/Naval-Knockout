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
    Radar
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

- (NSSet *)validMoveTiles;
- (NSSet *)validDropMineTiles;

@property (nonatomic, assign) ShipType shipType;
@property (nonatomic, assign) Direction dir;
@property (nonatomic, assign) int baseRow;
@property (nonatomic, assign) int baseColumn;
- (void)updateLocation;


- (void)performMoveActionTo:(Tile *)tile;

@property (nonatomic, assign) BOOL isEnemyShip;

@end
