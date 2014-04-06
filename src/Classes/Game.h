//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>
#import "GameState.h"


enum {
    StateTypeNone,
    StateTypeReefProposal, // This is the state we begin with in newGame
    StateTypeReefAccepting,
    StateTypeShipSetupLeft,
    StateTypeShipSetupRight,
    StateTypePlay
};
typedef NSInteger StateType;


@class shipTray, ShipCommandBar, GameManager, Tile;

@interface Game : SPSprite <UIAlertViewDelegate>

@property (nonatomic, strong) SPSprite *gridContainer;

@property (nonatomic, strong) SPJuggler *shipJuggler;

@property (nonatomic, strong) shipTray *shipsTray;
@property (nonatomic, strong) ShipCommandBar *shipCommandBar;

// All ships
@property (nonatomic, strong) NSMutableSet *myShips;
@property (nonatomic, strong) NSMutableSet *enemyShips;

@property (nonatomic, strong) SPSprite *content;

@property (nonatomic, assign) float tileSize;
@property (nonatomic, assign) int tileCount;
@property (nonatomic, strong) NSArray *tiles;

@property (nonatomic, weak) GameManager *delegate;

@property (nonatomic, assign) BOOL myTurn;

@property (nonatomic, readonly, assign) StateType currentStateType;

- (void)doneSettingShips;


- (NSDictionary *)getDataDictWithMyID:(NSString *)myID opponentID:(NSString *)oppID;
- (BOOL)checkVictoryWithMyID:(NSString *)myID;
- (void)receivedGame:(NSDictionary *)state;

- (void)performedAction;
- (void)notifyCannonCollision:(Tile *)tile;

- (void)newGame;
- (void)dismissMenu;

@end
