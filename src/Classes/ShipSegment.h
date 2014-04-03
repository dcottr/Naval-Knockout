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

- (void)setFogOfWar:(BOOL)foggy;
@property (nonatomic, assign) BOOL selectable;

@end
