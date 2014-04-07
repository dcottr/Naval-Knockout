//
//  Mine.h
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-12.
//
//

#import "SPSprite.h"

@class Tile;
@interface Mine : SPSprite

- (id)initWithTile:(Tile *)tile;
@property (nonatomic, weak) Tile *tile;

@end
