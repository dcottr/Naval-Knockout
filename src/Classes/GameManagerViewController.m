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

@interface GameManagerViewController ()

@property (nonatomic, strong) Game *game;

@end

@implementation GameManagerViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.showStats = YES;
    self.multitouchEnabled = YES;
    self.preferredFramesPerSecond = 60;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gameInitialized)
                                                 name:@"GameInitialized" object:nil];
    [self startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
    
	// Do any additional setup after loading the view.
}

- (void)gameInitialized
{
    _game = ((AppDelegate *)[UIApplication sharedApplication].delegate).game;
    NSLog(@"Game: %@", _game);
}

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    // Initiate game state setup?
    NSLog(@"Entering game");
}

- (void)layoutMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"LayoutMatch");
}

- (void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Taking turn");
    NSLog(@"Match Data: %@", [[NSString alloc] initWithData:match.matchData encoding:NSUTF8StringEncoding]);
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
    //    NSData *data = GameState.stateStuff;
    NSData *data;
    
    
    for (int i = 0; i < [currentMatch.participants count]; i++) {
        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1 + i) % [currentMatch.participants count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            NSLog(@"isnt' quit %@", nextParticipant);
            break;
        } else {
            NSLog(@"nex part %@", nextParticipant);
        }
    }
    
    if ([data length] > 3800) {
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
