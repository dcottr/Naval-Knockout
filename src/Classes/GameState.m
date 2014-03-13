//
//  GameState.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-12.
//
//

#import "GameState.h"

@implementation GameState


// gets called by gamemanagerviewcontroller after the local player makes a move
-(NSData *) DataFromState:(NSMutableDictionary *)gameState
{
  _state = [self populateDictionary:gameState];
  NSLog(@"stored data.");
  return [NSKeyedArchiver archivedDataWithRootObject:_state];
  
  
}

-(NSMutableDictionary *) populateDictionary:(NSDictionary *) board
{
  // fill dictionary with game board info.
  NSString * player = [GKLocalPlayer localPlayer].playerID;
  NSString * opp = [board keysOfEntriesPassingTest:
					^BOOL(id key, id obj, BOOL *stop):<#(NSString *)#>]
  if () {
	
  }
  return (NSMutableDictionary *) board;
}


// gets called after a player receives a turn and hasn't yet updated the game
-(void) DataToState:(NSData *) data
{
  @try
  {
	
	NSMutableDictionary *tempstate= (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
	_state = [tempstate copy];
      NSLog(@"NewState: %@", _state);
	// get opponent string here from dict keys
	/*
	
	 */
  }
  @catch(NSException * e)
  {
	NSLog(@"could not store game state from data!\n %@", e );
  }
  
}


@end
