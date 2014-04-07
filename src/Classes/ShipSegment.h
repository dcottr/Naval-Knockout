//
//  ShipSegment.h
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-14.
//
//

#import "SPSprite.h"

enum {
    ShipSegmentIndexBack,
    ShipSegmentIndexMid,
    ShipSegmentIndexFront
};
typedef NSInteger ShipSegmentIndex;

@class Tile, Ship;
@interface ShipSegment : SPSprite

@property (nonatomic, weak) Tile *tile;
@property (nonatomic, weak, readonly) Ship *ship;
@property (nonatomic, assign) int health; // integer ==> destroyed = 0, damaged = 1, intact = 2.
@property (nonatomic, assign) BOOL selectable;

- (id)initWithIndex:(ShipSegmentIndex)index ship:(Ship *)ship;
- (void)setFogOfWar:(BOOL)foggy;
- (void)hitByCannon;
- (void)hitByHeavyCannon;
- (void)updateSegmentDamage;
- (void)displayNotify:(BOOL)display;
@end
