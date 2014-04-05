//
//  Base.h
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-30.
//
//

#import "Ship.h"
#import "ShipsTray.h"


@interface Base : Ship


-(void)setVisible:(BOOL)visible;
-(BOOL)healShip:(Ship *)ship;
+(void)setSurroundingTilesVisible:(Base *) tail;


@property (nonatomic, assign) BOOL healthy;
@property (nonatomic, assign) BOOL didHealThisTurn;
@property (nonatomic, assign) NSInteger totalHealth;
@property (nonatomic, strong) Tile *myTile;
@property (nonatomic, strong) Base *tail;

@end
