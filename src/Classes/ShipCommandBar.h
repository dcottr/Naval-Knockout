//
//  ShipCommandBar.h
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "SPSprite.h"

@class Ship, Tile, Game;
@interface ShipCommandBar : SPSprite


- (void)setSelected:(Ship *)ship;
- (void)deselect;

- (void)selectTile:(Tile *)tile;

- (id)initWithGame:(Game *)game;
@end
