//
//  GameState.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-12.
//
//

#import "GameState.h"

@implementation GameState


// gets called by gamemanagerviewcontroller after a player makes a move
-(NSData *) DataFromState:(NSMutableDictionary *)gameState
{
  _state = [self populateDictionary:gameState];
  return [NSKeyedArchiver archivedDataWithRootObject:_state];
  NSLog(@"stored data.");
  
}

-(NSMutableDictionary *) populateDictionary:(NSDictionary *) board
{
  /*
   NSMutableData *data = [[NSMutableData alloc] init];
   NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
   [archiver encodeObject:_state forKey:@"Some Key Value"];
   [archiver finishEncoding];
   return data;
   */
  // fill dictionary with game board info.
  
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
	NSString * player = [GKLocalPlayer localPlayer].playerID;
	NSString * opp = [tempstate keysOfEntriesPassingTest:^BOOL(id key, id obj):<#(NSString *)#>]
	if () {
	  
	}
	 */
  }
  @catch(NSException * e)
  {
	NSLog(@"could not store game state from data!\n %@", e );
  }
  
}


@end
