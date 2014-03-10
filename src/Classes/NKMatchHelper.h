//
//  NKMatchHelper.h
//  GKAuthentication
//
//  Created by ivanfer on 2014-03-08.
//	This class houses the implementation and singleton for handling multiplayer matches.
//  This will authenticate the player every time the app is launched.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface NKMatchHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate>

@property (nonatomic, strong) UIViewController *presentingViewController;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (retain) GKTurnBasedMatch * currentMatch;

- (void)findMatchWithMinPlayers:(int)minPlayers
					 maxPlayers:(int)maxPlayers
				 viewController:(UIViewController *)viewController;

+ (NKMatchHelper *)sharedInstance;
- (void)authenticateLocalPlayer;

@end
