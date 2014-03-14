//
//  ShipSegment.h
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-14.
//
//

#import "SPSprite.h"

@class Tile;
@interface ShipSegment : SPSprite

@property (nonatomic, weak) Tile *tile;

- (void)setFogOfWar:(BOOL)foggy;
@property (nonatomic, assign) BOOL selectable;

@end
