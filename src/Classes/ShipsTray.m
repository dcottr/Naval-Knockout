//
//  ShipsTray.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "ShipsTray.h"
#import "Ship.h"
#import "Game.h"


@interface ShipsTray ()

@property (nonatomic, strong) SPImage *trayBar;
@property (nonatomic, weak) Game *game;
@property (nonatomic, strong) NSMutableSet *trayedShips;

@end

static SPTexture *trayBarTexture = nil;

@implementation ShipsTray


- (id)initWithGame:(Game *)game
{
    if (!trayBarTexture)
        trayBarTexture = [SPTexture textureWithContentsOfFile:@"Glossy05.png"];

    self = [super init];
    if (self) {
        _game = game;
        _trayedShips = [[NSMutableSet alloc] init];
        _trayBar = [[SPImage alloc] initWithTexture:trayBarTexture];
        _trayBar.width = Sparrow.stage.width;
        _trayBar.height = 100.0f;
        [self addChild:_trayBar];
    }
    return self;
}

- (void)presentShips:(NSArray *)ships
{
    NSNumber *shipType;
    Ship *ship;
    for (int i = 0; i < [ships count]; i++) {
        shipType = [ships objectAtIndex:i];
        ship = [[Ship alloc] initWithGame:_game type:shipType.intValue];
        ship.x = 10.0f + i * ship.width;
        ship.y = 10.0f + ship.height/2;
        [self addChild:ship];
        [_trayedShips addObject:ship];
    }
}

- (void)removedShip:(Ship *)ship
{
    [_trayedShips removeObject:ship];
    [_game.myShips addObject:ship];
    if ([_trayedShips count] <= 0) {
        [self allShipsPlaced];
    }
}

- (void)allShipsPlaced
{
    SPTexture *checkButtonTexture = [SPTexture textureWithContentsOfFile:@"green_checkmark.png"];
    SPButton *checkButton = [[SPButton alloc] initWithUpState:checkButtonTexture];
    checkButton.x = Sparrow.stage.width - checkButton.width - 30.0f;
    checkButton.y = (self.height - checkButton.height)/2;
    [self addChild:checkButton];
    [checkButton addEventListener:@selector(done:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    [self removeChild:_trayBar];
}


- (void)done:(SPTouchEvent *)event
{
    [_game doneSettingShips];
}
@end
