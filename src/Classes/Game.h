//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>
#import "GameState.h"
@class ShipsTray, ShipCommandBar, GameManagerViewController;

@interface Game : SPSprite

@property (nonatomic, strong) SPSprite *gridContainer;

@property (nonatomic, strong) SPJuggler *shipJuggler;

@property (nonatomic, strong) ShipsTray *shipsTray;
@property (nonatomic, strong) ShipCommandBar *shipCommandBar;

// All ships
@property (nonatomic, strong) NSMutableSet *myShips;
@property (nonatomic, strong) NSMutableSet *enemyShips;

@property (nonatomic, strong) SPSprite *content;

@property (nonatomic, assign) float tileSize;
@property (nonatomic, assign) int tileCount;
@property (nonatomic, strong) NSArray *tiles;

@property (nonatomic, weak) GameManagerViewController *delegate;

- (void)doneSettingShips;


- (NSDictionary *)getDataDictWithMyID:(NSString *)myID opponentID:(NSString *)oppID;

- (void)newState:(NSDictionary *)state;

@end
