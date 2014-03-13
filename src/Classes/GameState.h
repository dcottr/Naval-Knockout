//
//  GameState.h
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-12.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@interface GameState : NSObject

@property (nonatomic, strong) NSString *playerKey;

@property (nonatomic, strong) NSMutableDictionary *state;
-(NSData *) DataFromState:(NSDictionary *)gameState;
-(NSMutableDictionary *) updateState:(NSDictionary *)board;
-(NSMutableDictionary *) DataToState:(NSData *) data;
//-(NSArray *) compareToNewState:(NSMutableDictionary *) newState;


/*
 
 dictionary format:
 player1 id -> dict of ships
 player2 id -> dict of ships
 @"mines"	-> mine positons
 
 future implementations:
 +base health (as a ship)
 +last move
 
 
*/

@end
