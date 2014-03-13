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

- (id)init
{
    self = [super init];
    if (self) {
        _gameState = [[GameState alloc] init];
        
        self.showStats = YES;
        self.multitouchEnabled = YES;
        self.preferredFramesPerSecond = 60;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(gameInitialized)
                                                     name:@"GameInitialized" object:nil];
        [self startWithRoot:[Game class] supportHighResolutions:YES];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIInterfaceOrientation orientation = self.interfaceOrientation;

//    [self rotateToInterfaceOrientation:orientation animationTime:0];
    
    NSLog(@"MAtch DATa: %@", _gameState.state);
    
	// Do any additional setup after loading the view.
}

- (void)gameInitialized
{
    _game = ((AppDelegate *)[UIApplication sharedApplication].delegate).game;
    [_game setDelegate:self];
    NSLog(@"Game: %@", _game);
}

- (void)enterNewGame:(GKTurnBasedMatch *)match
{
    // Initiate game state setup?
    NSLog(@"Entering game");
}

// Called when entering a game whether or not it is your turn
- (void)layoutMatch:(GKTurnBasedMatch *)match
{
    NSLog(@"LayoutMatch");
}

- (void)takeTurn:(GKTurnBasedMatch *)match
{
    NSLog(@"Taking turn");
    [_gameState DataToState:match.matchData];
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
    NSLog(@"data length: %d", [data length]);
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
