//
//  ShipCommandBar.h
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "SPSprite.h"

@class Ship, Tile;
@interface ShipCommandBar : SPSprite


- (void)setSelected:(Ship *)ship;
- (void)deselect;

- (void)selectTile:(Tile *)tile;

@end
