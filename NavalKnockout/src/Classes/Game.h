//
//  Game.h
//  AppScaffold
//

#import <Foundation/Foundation.h>
#import <UIKit/UIDevice.h>

@class ShipsTray;

@interface Game : SPSprite

@property (nonatomic, strong) SPSprite *gridContainer;
@property (nonatomic, strong) SPSprite *shipsTray;
@property (nonatomic, strong) SPJuggler *shipJuggler;

@property (nonatomic, strong) SPSprite *content;

@property (nonatomic, assign) float tileSize;

@end
