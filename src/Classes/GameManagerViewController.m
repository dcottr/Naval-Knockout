//
//  GameManagerViewController.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-09.
//
//

#import "AppDelegate.h"
#import "GameManagerViewController.h"
#import "NKMatchHelper.h"
#import "Game.h"
#import "GameState.h"

@interface GameManagerViewController ()

@property (nonatomic, strong) Game *game;
@property (nonatomic, strong) GameState *gameState;

@end

@implementation GameManagerViewController

- (id)initWithGame:(Game *)game
{
    self = [super init];
    if (self) {
        _gameState = [[GameState alloc] init];
        _game = game;
    }
    return self;
}

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    NSLog(@"Match Data: %@", _gameState.state);
//    
//	// Do any additional setup after loading the view.
//}

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    // Initiate game state setup?
    [_gameState DataToState:match.matchData];
    NSLog(@"Entering game");
    if (_game) {
        [_game newGame];
//        [_game newState:_gameState.state];
    }
}

// It's not your turn, just display the game state.  (Seems buggy, test-test-test!)
- (void)layoutMatch:(GKTurnBasedMatch *)match
{
    [_gameState DataToState:match.matchData];
    NSLog(@"LayoutMatch: %@", _gameState.state);
//    [_gameState DataToState:match.matchData];
    if (_game) {
        [_game newState:_gameState.state];
    }
}

- (void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Taking turn");
    [_gameState DataToState:match.matchData];
    if (_game) {
        [_game newState:_gameState.state];
    }
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match
{
    
}

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match
{
    
}

- (void)sendTurn
{
    if(!_game) {
        NSLog(@"Game is not yet initialized");
    }
    
    GKTurnBasedMatch *currentMatch = [[NKMatchHelper sharedInstance] currentMatch];
    
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    NSUInteger nextIndex = (currentIndex + 1) % [currentMatch.participants count];
    GKTurnBasedParticipant *nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    
    NSString *myID = [GKLocalPlayer localPlayer].playerID;
    NSString *oppID = nextParticipant.playerID;
    NSDictionary *gameDataDict = [_game getDataDictWithMyID:myID opponentID:oppID];
    NSLog(@"Sending turn: %@", gameDataDict);
    NSData *data = [_gameState DataFromState:gameDataDict];
    
    for (int i = 0; i < [currentMatch.participants count]; i++) {
        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1 + i) % [currentMatch.participants count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            NSLog(@"isnt' quit %@", nextParticipant);
            break;
        } else {
            NSLog(@"nex part %@", nextParticipant);
        }
    }
    NSLog(@"data length: %lu", [data length]);
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
        //	statusLabel.text = @"Game has ended";
    } else {
        [currentMatch endTurnWithNextParticipant:nextParticipant matchData:data completionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"%@", error);
                //		statusLabel.text = @"Oops, there was a problem.  Try that again.";
            } else {
                //		statusLabel.text = @"Your turn is over.";
                //		textInputField.enabled = NO;
            }
        }];
    }
    
    NSLog(@"Send Turn, %@, %@", data, nextParticipant);
}


@end
