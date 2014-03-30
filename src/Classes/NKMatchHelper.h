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


@protocol NKMatchHelperDelegate
// TEMP

- (void)sendTurn;

//
- (void)enterNewGame:(GKTurnBasedMatch *)match;
- (void)layoutMatch:(GKTurnBasedMatch *)match;
- (void)takeTurn:(GKTurnBasedMatch *)match;
- (void)recieveEndGame:(GKTurnBasedMatch *)match;
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match;

@end


@class MenuViewController;
@interface NKMatchHelper : NSObject <GKTurnBasedMatchmakerViewControllerDelegate, GKLocalPlayerListener>

@property (nonatomic, strong) MenuViewController *menuViewController;
@property (assign, readonly) BOOL gameCenterAvailable;
@property (assign, readonly) BOOL userAuthenticated;
@property (retain) GKTurnBasedMatch * currentMatch;

@property (nonatomic, strong) id <NKMatchHelperDelegate> delegate;

- (void)findMatchWithMinPlayers:(int)minPlayers
					 maxPlayers:(int)maxPlayers
				 viewController:(MenuViewController *)viewController;

+ (NKMatchHelper *)sharedInstance;
- (void)authenticateLocalPlayer;

@end
