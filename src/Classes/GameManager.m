//
//  GameManagerViewController.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-09.
//
//

#import "AppDelegate.h"
#import "GameManager.h"
#import "NKMatchHelper.h"
#import "Game.h"
#import "GameState.h"

@interface GameManager ()

@property (nonatomic, strong) Game *game;
@property (nonatomic, strong) GameState *gameState;

@end

@implementation GameManager

- (id)initWithGame:(Game *)game
{
    self = [super init];
    if (self) {
        _gameState = [[GameState alloc] init];
        _game = game;
    }
    return self;
}

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    // Initiate game state setup?
    [_gameState DataToState:match.matchData];
    NSLog(@"Entering game");
    if (_game) {
        [_game newGame];
    }
}

// It's not your turn, just display the game state.  (Seems buggy, test-test-test!)
- (void)layoutMatch:(GKTurnBasedMatch *)match
{
    [_gameState DataToState:match.matchData];
    NSLog(@"LayoutMatch: %@", _gameState.state);
    if (_game) {
        [_game receivedGame:_gameState.state];
    }
}

- (void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Taking turn");
    [_gameState DataToState:match.matchData];
    if (_game) {
        [_game receivedGame:_gameState.state];
    }
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match
{
    [_gameState DataToState:match.matchData];
    if (_game) {
        [_game receivedGame:_gameState.state];
    }
    NSString *myID = [GKLocalPlayer localPlayer].playerID;
    for (GKTurnBasedParticipant *participant in match.participants) {
        if ([participant.playerID isEqualToString:myID]) {
            if (participant.matchOutcome == GKTurnBasedMatchOutcomeWon) {
                [self presentVictory:YES];
            } else if (participant.matchOutcome == GKTurnBasedMatchOutcomeTied) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tie!" message:@"" delegate:_game cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            } else if (participant.matchOutcome == GKTurnBasedMatchOutcomeWon) {
                [self presentVictory:NO];
            }
            return;
        }
    }
}

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match
{
    
}

- (void)sendTurn
{
    
    GKTurnBasedMatch *currentMatch = [[NKMatchHelper sharedInstance] currentMatch];
    
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    NSUInteger nextIndex = (currentIndex + 1) % [currentMatch.participants count];
    GKTurnBasedParticipant *nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    
    NSString *myID = [GKLocalPlayer localPlayer].playerID;
    NSString *oppID = nextParticipant.playerID;
    BOOL victory = [_game checkVictoryWithMyID:myID];
    NSDictionary *gameDataDict = [_game getDataDictWithMyID:myID opponentID:oppID];
    NSLog(@"Sending turn: %@", gameDataDict);
    NSData *data = [_gameState DataFromState:gameDataDict];
    
    //    for (int i = 0; i < [currentMatch.participants count]; i++) {
    //        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1 + i) % [currentMatch.participants count ])];
    //        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
    //            NSLog(@"isnt' quit %@", nextParticipant);
    //            break;
    //        } else {
    //            NSLog(@"nex part %@", nextParticipant);
    //        }
    //    }
    
    NSLog(@"data length: %lu", (unsigned long)[data length]);
    if ([data length] > 8 * 1024) {
        NSLog(@"Data more than 3,800 so ending match");
        for (GKTurnBasedParticipant *part in currentMatch.participants) {
            part.matchOutcome = GKTurnBasedMatchOutcomeTied;
        }
        [currentMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tie!" message:@"" delegate:_game cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        if (victory) {
            for (GKTurnBasedParticipant *participant in currentMatch.participants) {
                if ([participant.playerID isEqualToString:myID]) {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeWon;
                } else {
                    participant.matchOutcome = GKTurnBasedMatchOutcomeLost;
                }
            }
            [currentMatch endMatchInTurnWithMatchData:data completionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"ERROR: %@", error);
                }
            }];
            [self presentVictory:YES];
        } else {
            [currentMatch endTurnWithNextParticipant:nextParticipant matchData:data completionHandler:^(NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Center failing" message:@"Try reloading the game :'(" delegate:_game cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                } else {
                    
                }
            }];
        }
    }
}

- (void)presentVictory:(BOOL)victory
{
    UIAlertView *alert;
    if (victory) {
        alert = [[UIAlertView alloc] initWithTitle:@"Aww Yis" message:@"You won!" delegate:_game cancelButtonTitle:@"YES" otherButtonTitles:nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"Defeat!" message:@"You have lost the game" delegate:_game cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    [alert show];

}

@end
