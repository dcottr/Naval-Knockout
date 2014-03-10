//
//  NKMatchHelper.m
//  GKAuthentication
//
//  Created by ivanfer on 2014-03-08.
//
//

#import "NKMatchHelper.h"


@implementation NKMatchHelper

#pragma mark Init_MatchHelper

@synthesize gameCenterAvailable;
@synthesize currentMatch;

static NKMatchHelper *sharedHelper = nil;



+ (NKMatchHelper *) sharedInstance {
  if (!sharedHelper){
	sharedHelper = [[NKMatchHelper alloc] init];
  }
  return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
  // check for presence of GKLocalPlayer API
  Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
  
  // check if the device is running iOS 4.1 or later
  NSString *reqSysVer = @"4.1";
  NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
  BOOL osVersionSupported = ([currSysVer compare:reqSysVer
										 options:NSNumericSearch] != NSOrderedAscending);
  
  return (gcClass && osVersionSupported);
}

- (id)init {
  if ((self = [super init])) {
	gameCenterAvailable = [self isGameCenterAvailable];
	if (gameCenterAvailable) {
	  NSNotificationCenter *nc =
	  [NSNotificationCenter defaultCenter];
	  [nc addObserver:self
			 selector:@selector(authenticationChanged)
				 name:GKPlayerAuthenticationDidChangeNotificationName
			   object:nil];
	}
  }
  return self;
}

- (void)authenticationChanged {
  
  if ([GKLocalPlayer localPlayer].isAuthenticated &&
      !_userAuthenticated) {
	NSLog(@"Authentication changed: player authenticated.");
	_userAuthenticated = TRUE;
  } else if (![GKLocalPlayer localPlayer].isAuthenticated &&
			 _userAuthenticated) {
	NSLog(@"Authentication changed: player not authenticated");
	_userAuthenticated = FALSE;
  }
  
}

- (void)authenticateLocalPlayer
{
  GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];

  localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
	NSLog(@"Authenticated with error: %@", error);
	if (viewController != nil)
	{
	  
	  
	  [_presentingViewController presentViewController:viewController animated:YES completion:nil];
	  //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
//	  [self showAuthenticationDialogWhenReasonable: viewController];
	}
	else if (localPlayer.isAuthenticated)
	{
#pragma mark("TODO: If no active game:")
	  [[NKMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:_presentingViewController];
	  //authenticatedPlayer: is an example method name. Create your own method that is called after the loacal player is authenticated.
	  //[self authenticatedPlayer: localPlayer];
	}
	else
	{
	  //[self disableGameCenter];
	}
  };
}

- (void)findMatchWithMinPlayers:(int)minPlayers
					 maxPlayers:(int)maxPlayers
				 viewController:(UIViewController *)viewController {
  if (!gameCenterAvailable) return;
  
  _presentingViewController = viewController;
  
  GKMatchRequest *request = [[GKMatchRequest alloc] init];
  request.minPlayers = minPlayers;
  request.maxPlayers = maxPlayers;
  
  GKTurnBasedMatchmakerViewController *mmvc =
  [[GKTurnBasedMatchmakerViewController alloc]
   initWithMatchRequest:request];
  mmvc.turnBasedMatchmakerDelegate = self;
  mmvc.showExistingMatches = YES;
  
  [_presentingViewController presentViewController:mmvc animated:YES completion:nil];
}


-(void)turnBasedMatchmakerViewControllerWasCancelled:
(GKTurnBasedMatchmakerViewController *)viewController {
  [_presentingViewController
   dismissViewControllerAnimated:YES completion:nil];
  NSLog(@"has cancelled");
}

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
						didFailWithError:(NSError *)error {
  [_presentingViewController
   dismissViewControllerAnimated:YES completion:nil];
  NSLog(@"Error finding match: %@", error.localizedDescription);
}

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
					  playerQuitForMatch:(GKTurnBasedMatch *)match {
  NSLog(@"playerquitforMatch, %@, %@",
		match, match.currentParticipant);
}

-(void)turnBasedMatchmakerViewController:
(GKTurnBasedMatchmakerViewController *)viewController
							didFindMatch:(GKTurnBasedMatch *)match {
  [_presentingViewController
   dismissViewControllerAnimated:YES completion:nil];
   // dismissModalViewControllerAnimated:YES];
  NSLog(@"did find match, %@", match);
  self.currentMatch = match;
}

@end
