//
//  GameManagerViewController.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-09.
//
//

#import "GameManagerViewController.h"
#import "NKMatchHelper.h"
#import "Game.h"

@interface GameManagerViewController ()

@end

@implementation GameManagerViewController

- (id)init
{
  self = [super init];
  if (self) {
	self.showStats = YES;
    self.multitouchEnabled = YES;
    self.preferredFramesPerSecond = 60;
    
    [self startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match
{
  
}

- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match
{
  
}

- (void)sendTurn
{
  GKTurnBasedMatch *currentMatch = [[NKMatchHelper sharedInstance] currentMatch];
  
  NSString *sendString = @"Hello World";
  NSData *data = [sendString dataUsingEncoding:NSUTF8StringEncoding ];
  
  NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
  GKTurnBasedParticipant *nextParticipant;
  
  NSUInteger nextIndex = (currentIndex + 1) % [currentMatch.participants count];
  nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
  
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
