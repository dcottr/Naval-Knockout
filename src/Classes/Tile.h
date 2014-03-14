//
//  Tile.h
//  Scaffold
//
//  Created by David Cottrell on 2014-03-05.
//
//

#import "SPSprite.h"
#import "Game.h"

@interface Tile : SPSprite

- (id)initWithGame:(Game *)game row:(int)r column:(int)c;
@property (nonatomic, assign) int row;
@property (nonatomic, assign) int col;
@property (nonatomic, assign) BOOL hasMine;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, assign) BOOL visible;

- (void)performMineAction;

@end
