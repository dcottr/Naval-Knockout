//
//  ShipsTray.h
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "SPSprite.h"

@class Game, Ship;
@interface ShipsTray : SPSprite

- (void)presentShips:(NSArray *)ships;
- (id)initWithGame:(Game *)game;
- (void)removedShip:(Ship *)ship;

@end
