//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>

@class ShipsTray, ShipCommandBar;

@interface Game : SPSprite

@property (nonatomic, strong) SPSprite *gridContainer;

@property (nonatomic, strong) SPJuggler *shipJuggler;

@property (nonatomic, strong) ShipsTray *shipsTray;
@property (nonatomic, strong) ShipCommandBar *shipCommandBar;

// All ships
@property (nonatomic, strong) NSMutableSet *ships;

@property (nonatomic, strong) SPSprite *content;

@property (nonatomic, assign) float tileSize;
@property (nonatomic, assign) int tileCount;

- (void)doneSettingShips;

@end
