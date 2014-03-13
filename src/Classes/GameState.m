//
//  GameState.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-12.
//
//

#import "GameState.h"

@implementation GameState


// gets called by gamemanagerviewcontroller
-(NSData *) DataFromState
{
  if(_state){
	/*
	NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	[archiver encodeObject:_state forKey:@"Some Key Value"];
	[archiver finishEncoding];
	return data;
	 */
	return [NSKeyedArchiver archivedDataWithRootObject:_state];
  }
  else
  {
	NSLog(@"this game does not exist!!");
	return nil;
  }
}

-(NSMutableDictionary *) populateDictionary:(NSDictionary *) board
{
  
  // fill dictionary with game board info.
  
  return nil;
}

-(void) DataToState:(NSData *) data
{
  @try
  {
	
	NSMutableDictionary *tempstate= (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
	_state = [tempstate copy];
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
