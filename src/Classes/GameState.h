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

@property (nonatomic, strong) NSMutableDictionary *state;
-(NSData *) DataFromState:(NSDictionary *)gameState;
-(NSMutableDictionary *) populateDictionary:(NSDictionary *)board;
-(void)DataToState:(NSData *) data;


/*
 
 dictionary format:
 player1 id -> dict of ships
 player2 id -> dict of ships
 @"mines"	-> mine positons
 
 future implementations:
 +base health
 +last move
 
 
*/

@end
