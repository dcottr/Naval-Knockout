//
//  ShipSegment.h
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-14.
//
//

#import "SPSprite.h"

@class Tile, Ship;
@interface ShipSegment : SPSprite

@property (nonatomic, weak) Tile *tile;
@property (nonatomic, weak) Ship *ship;
@property (nonatomic, assign) int health; // integer ==> destroyed = 0, damaged = 1, intact = 2.

- (void)setFogOfWar:(BOOL)foggy;
@property (nonatomic, assign) BOOL selectable;

- (void)hitByCannon;
- (void)updateTileDamage;

@end
