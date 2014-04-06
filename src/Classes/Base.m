//
//  Base.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-30.
//
//

#import "Base.h"
#import "Tile.h"
#import "Game.h"
#import "Ship.h"

@interface Base ()

@property (nonatomic, weak) ShipsTray *trayContainer;
@property (nonatomic, weak) SPSprite *gridContainer;
@property (nonatomic, weak) Game *gameContainer;


@property (nonatomic, strong) SPImage *shipImage;




@end

static SPTexture * baseTexture = nil;
static SPTexture * healthyBase = nil;
static SPTexture * damagedBase = nil;
static SPTexture * disabledBase = nil;

static BOOL texturesInitialized = NO;


static Base * myTail = nil;
static Base * enemyTail = nil;

@implementation Base

/*
 TODO:
 decode game state into active base
 encode base into state
 check healing 
 change sprite on hit
 assign tail on init
 
 health: 2 is full life 0 is dead
*/


-(id)initWithGame:(Game *)game type:(ShipType)type{
  if (!texturesInitialized){
//	healthyBase = [SPTexture textureWithContentsOfFile:@"base_healthy.png"];
	//damagedBase = [SPTexture textureWithContentsOfFile:@"base_weak.png"];
	//disabledBase = [SPTexture textureWithContentsOfFile:@"base_dead.png"];
  }
  if (!baseTexture){
	baseTexture = healthyBase;
  }
  if (self = [super initWithGame:game type:BaseType]){
	self.shipImage = [[SPImage alloc] initWithTexture:baseTexture];
	[self removeEventListenersAtObject:self forType:SP_EVENT_TYPE_TOUCH];
	self.baseRow = 9;
	self.dir = Up;
  }
  return self;
}

- (void) setIsEnemyShip:(BOOL)isEnemyShip{
  self.isEnemyShip = isEnemyShip;
}

-(void)setVisible:(BOOL)visible {
  self.visible = visible;
}

//	heals a given ship docked next to base instance
-(BOOL)healShip:(Ship *)ship{
  if (!ship.isEnemyShip){
	if (self.healthy && self.didHealThisTurn){
	  //ship.health = ship.health + 1;
	  
	  //  update tile overlay back to previous damage state
	  //  animate healing
	}
	else{
	  NSLog(@"This base can't heal this ship");
	  return NO;
	}
  return YES;
  }
  NSLog(@"can't heal the enemy lel");
  return NO;
  
}
/*
-(void)hitByCannon{
  if (self.health ==2){
	 // self.health = 1;
	[self updateTilesOccupied];
#pragma message(" needs to deal with shipsegments, left incomplete")
  }
  NSLog(@" Base hit by cannon");
  
}
*/
//	this should only change the health sprites
/*-(void)updateTilesOccupied{
  if (self.health ==1){
	// change sprite to disabled, change ability to heal
	self.health = 0;
	self.healthy = NO;
	
  }
  else if(self.health == 2){
	self.health = 1;
	
  }
}
*/
//	take tail of a given player base (bottom tile)
//	and set visibility
//	of everything around it
-(void)setSurroundingTilesVisible{
  return;
}
  
/*+(void)setSurroundingTilesVisible:(Base *) base{
  Tile *t = base.tail.myTile;
  Game *gc=[base gameContainer];
  // only set the base tiles themselves visibile if enemy
  if (base.isEnemyShip){
	for (int i =  t.row; i<= t.row + NKBASESIZE; i ++){
	  Tile *ij =  [[gc.tiles
					objectAtIndex:i] objectAtIndex:t.col];
	  [ij fogOfWar:NO];
	  [ij setVisible:YES];
	}
  }
  // set visible all adjacent tiles to entire base
  else{
	for ( int i = t.col -1; i<=t.col+1;){
	  for (int j = t.row-1; j <= t.row+NKBASESIZE; j++ ){
		if (i >= 0 || i <= gc.tileCount){
		  Tile *ij = [[gc.tiles objectAtIndex:j] objectAtIndex:i];
		  [ij fogOfWar:NO];
		  [ij setVisible:YES];
		  
		  
		// TODO: add any more visibility checks
		}
	  }
	}
  }
}

*/



@end
