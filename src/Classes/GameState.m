//
//  GameState.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-12.
//
//

#import "GameState.h"

@implementation GameState

@synthesize playerKey;

// gets called by gamemanagerviewcontroller after the local player makes a move
-(NSData *) DataFromState:(NSMutableDictionary *)gameState
{
  // update state to latest
  [self updateState:gameState];
  // give data corresponding to
  return [NSKeyedArchiver archivedDataWithRootObject:gameState];
  
  
}

-(NSMutableDictionary *) updateState:(NSDictionary *) board
{
  
  if(![board valueForKey:[GKLocalPlayer localPlayer].playerID]){
	// Init Game: Got their game state , local player's is absent. add it:
	[board setValue:[_state valueForKey:self.playerKey]
			 forKey:self.playerKey];
  }
  _state = [board copy];
    NSLog(@"NewState: %@", _state);
  return (NSMutableDictionary *) board;
}


// gets called after a player receives a turn and hasn't yet updated the game
-(NSMutableDictionary *) DataToState:(NSData *) data
{
    
  @try
  {
	
	NSMutableDictionary *tempstate= (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
      
	[self updateState: tempstate];

	// optional: call to update viewController (observer)
  }
  @catch(NSException * e)
  {
	NSLog(@"could not store game state from data!\n %@", e );
  }
    return _state;
  
  return nil;
}

//-(NSArray *) compareToNewState:(NSMutableDictionary *)newState
//{
//  
//}
//

@end
