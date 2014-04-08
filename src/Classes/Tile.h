//
//  Tile.h
//  Scaffold
//
//  Created by David Cottrell on 2014-03-05.
//
//

#import "SPSprite.h"
#import "Game.h"

@class Ship, ShipSegment, Mine;
@interface Tile : SPSprite

- (id)initWithGame:(Game *)game row:(int)r column:(int)c;
@property (nonatomic, assign) int  row;
@property (nonatomic, assign) int  col;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, assign) BOOL reef;
@property (nonatomic, assign) BOOL sunk;


@property (nonatomic, strong) Ship *myShip; // Replace with myShipSegment
@property (nonatomic, strong) ShipSegment *myShipSegment;
@property (nonatomic, strong) Mine *mine;

- (void)cleanTile;


- (void)performMineAction;
- (void)performCannonAction;
- (void)performHeavyCannonAction;
- (void)performTorpedoAction;
- (void)displayCannonHit:(BOOL)display;
- (void)notifyEvent;

- (void)setSunk;

- (void)fogOfWar:(BOOL)visible;

- (void)setSonar:(BOOL)visible;
- (BOOL)isBase;

- (void)addMineTrigger:(Mine *)mine;

- (BOOL)collide:(Ship *)ship shipSegment:(ShipSegment *)segment;

- (void)removeMine;
- (void)performKamikazeAction;

@end
