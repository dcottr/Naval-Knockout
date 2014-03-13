//
//  Game.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Game.h"
#import "Ship.h"
#import "ShipsTray.h"
#import "ShipCommandBar.h"
#import "Tile.h"
#import "GameManagerViewController.h"

@interface Game () {
	bool isGrabbed;
    bool isPinched;
    bool shipGrabbed;
    float shipOffsetX;
    float shipOffsetY;
}

- (void)setup;



@end


@implementation Game


- (id)init
{
    if ((self = [super init])) {
        _tileSize = 32.0f;
        _tileCount = 32;
        _myShips = [[NSMutableSet alloc] init];
        _enemyShips = [[NSMutableSet alloc] init];        
        [self setup];
        [((AppDelegate *)[UIApplication sharedApplication].delegate) setGame:self];
    }
    return self;
}


- (void)newState:(NSDictionary *)state
{
    NSString *myId = [GKLocalPlayer localPlayer].playerID;
    NSLog(@"My id: %@", myId);
    
    if (state == nil || [state objectForKey:myId] == nil || [((NSDictionary *)[state objectForKey:myId]) count] == 0) {
        NSLog(@"Setup phase");
        
        
        int gameHeight = Sparrow.stage.height;
        _shipsTray = [[ShipsTray alloc] initWithGame:self];
        _shipsTray.y = gameHeight - 100.0f;
        _shipsTray.x = 0.0f;
        [self addChild:_shipsTray];
        
        
        NSArray *ships = [NSArray arrayWithObjects:num(Torpedo), num(Miner), nil];
        [_shipsTray presentShips:ships];

        
        if (state) {
            NSArray *enemyShips;
            for (NSString *enemyId in [state allKeys]) {
                if (![enemyId isEqualToString:@"Mines"] && ![enemyId isEqualToString:myId]) {
                    NSLog(@"enemyKey: %@", enemyId);
                    enemyShips = [state objectForKey:enemyId];
                    break;
                }
            }
            if (enemyShips) {
                [self setupEnemyShips:enemyShips];
            }
        }
    } else {
        NSLog(@"Not setup phase");
        
        // Need to position ships onto tiles
        // Need to create and drop ships
        
        if (!_shipsTray) {
            NSLog(@"shipsTray not initialized");
        } else {
            [self removeChild:_shipsTray];
            _shipsTray = nil;
        }
        if (_shipCommandBar) {
            [_shipCommandBar deselect];
        } else {
            _shipCommandBar = [[ShipCommandBar alloc] init];
            _shipCommandBar.y = Sparrow.stage.height - 100.0f;
            _shipCommandBar.x = 0.0f;
            [self addChild:_shipCommandBar];
        }
        
        
        
        NSArray *myShips = [state objectForKey:myId];
        [self setupMyShips:myShips];
        
        NSArray *enemyShips;
        for (NSString *enemyId in [state allKeys]) {
            if (![enemyId isEqualToString:@"Mines"] && ![enemyId isEqualToString:myId]) {
                NSLog(@"enemyKey: %@", enemyId);
                enemyShips = [state objectForKey:enemyId];
                break;;
            }
        }
        if (enemyShips) {
            [self setupEnemyShips:enemyShips];
        }
        
    }

}

- (void)setupMyShips:(NSArray *)myShips
{
    for (Ship *ship in _myShips) {
        [ship removeFromParent];
    }
    
    _myShips = [[NSMutableSet alloc] init];
    for (NSArray *shipAttrs in myShips) {
        Ship *newShip = [[Ship alloc] initWithGame:self type:(ShipType)([(NSNumber *)[shipAttrs objectAtIndex:3] intValue])];
        newShip.baseRow = ([(NSNumber *)[shipAttrs objectAtIndex:0] intValue]);
        newShip.baseColumn = ([(NSNumber *)[shipAttrs objectAtIndex:1] intValue]);
        newShip.dir = ([(NSNumber *)[shipAttrs objectAtIndex:2] intValue]);
        [_myShips addObject:newShip];
        
        [_gridContainer addChild:newShip];
        [newShip positionedShip];
        [newShip updateLocation];
        
    }
}

- (void)setupEnemyShips:(NSArray *)enemyShips
{
    for (Ship *ship in _enemyShips) {
        [ship removeFromParent];
    }
    
    _enemyShips = [[NSMutableSet alloc] init];
    for (NSArray *shipAttrs in enemyShips) {
        Ship *newShip = [[Ship alloc] initWithGame:self type:(ShipType)([(NSNumber *)[shipAttrs objectAtIndex:3] intValue])];
        newShip.baseRow = ([(NSNumber *)[shipAttrs objectAtIndex:0] intValue]);
        newShip.baseColumn = ([(NSNumber *)[shipAttrs objectAtIndex:1] intValue]);
        newShip.dir = ([(NSNumber *)[shipAttrs objectAtIndex:2] intValue]);
        [_enemyShips addObject:newShip];
        
        [_gridContainer addChild:newShip];
        [newShip setIsEnemyShip:YES];
        [newShip updateLocation];
        
    }
}


- (NSDictionary *)getDataDictWithMyID:(NSString *)myID opponentID:(NSString *)oppID
{
    
    NSMutableArray *myShips = [[NSMutableArray alloc] init];
    for (Ship *ship in _myShips) {
        NSArray *shipAttrs = [NSArray arrayWithObjects:num(ship.baseRow), num(ship.baseColumn), num(ship.dir), num(ship.shipType), nil];
        [myShips addObject:shipAttrs];
    }
    
    NSMutableArray *enemyShips = [[NSMutableArray alloc] init];
    for (Ship *ship in _enemyShips) {
        NSArray *shipAttrs = [NSArray arrayWithObjects:num(ship.baseRow), num(ship.baseColumn), num(ship.dir), num(ship.shipType), nil];
        [enemyShips addObject:shipAttrs];
    }
    
    NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:myShips, myID, enemyShips, oppID, nil];
    return result;
    
    
    // Mine stuff
//    NSMutableArray *mines = [[NSMutableArray alloc] init];
//    for (NSArray *column in _tiles) {
//        for (Tile *tile in column) {
//            if (tile.hasMine) {
//                NSArray *position = [NSArray arrayWithObjects:num(tile.row), num(tile.col), nil];
//                [mines addObject:position];
//            }
//        }
//    }
    
    
}

- (void)dealloc
{
    // release any resources here
    [Media releaseAtlas];
    [Media releaseSound];
}

- (void)setup
{
    
//    [SPAudioEngine start];  // starts up the sound engine
    
    
    _content = [[SPSprite alloc] init];
    _gridContainer = [[SPSprite alloc] init];
    
    [self addChild:_content];
    
    
    [_content addChild:_gridContainer];
    
    NSMutableArray *tiles = [[NSMutableArray alloc] init];
    for (int i = 0; i < _tileCount; i++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        for (int j = 0; j < _tileCount; j++) {
            Tile *tile = [[Tile alloc] initWithGame:self row:j column:i];
            
            tile.x = i * _tileSize;
            tile.y = j * _tileSize;
            
            [_gridContainer addChild:tile];
            [column addObject:tile];
        }
        [tiles addObject:[NSArray arrayWithArray:column]];
    }
    
    _tiles = [NSArray arrayWithArray:tiles];
    
    _shipJuggler = [[SPJuggler alloc] init];
    [self addEventListener:@selector(advanceJugglers:) atObject:self forType:SP_EVENT_TYPE_ENTER_FRAME];
    
    
    int gameHeight = Sparrow.stage.height;
    _shipsTray = [[ShipsTray alloc] initWithGame:self];
    _shipsTray.y = gameHeight - 100.0f;
    _shipsTray.x = 0.0f;
    [self addChild:_shipsTray];
    
    
    NSArray *ships = [NSArray arrayWithObjects:num(Torpedo), num(Miner), nil];
    [_shipsTray presentShips:ships];

    [_gridContainer addEventListener:@selector(scrollGrid:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
}

//- (void)setupShipsTray
//{
//
//}

- (void)scrollGrid:(SPTouchEvent *)event
{
    NSArray *touches = [[event touchesWithTarget:_gridContainer andPhase:SPTouchPhaseMoved] allObjects];
    SPTouch *touchUp = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    

    
    if (touches.count == 0) {
        if (touchUp) {
            if (!isGrabbed && !isPinched) {
                [self tapGrid:touchUp];
//                if (_shipCommandBar) {
//                    [_shipCommandBar deselect];
//                }
            }
            isGrabbed = NO;
            isPinched = NO;
            return;
        }
    } else if (touches.count == 1) {
        if (!isGrabbed) {
            isGrabbed = YES;
        }
        
        SPTouch *touch = touches[0];
        SPPoint *movement = [touch movementInSpace:_content.parent];
        
        _content.x += movement.x;
        _content.y += movement.y;

        // Doesn't work, since pivot changes on drag....
//        newY = _content.y + movement.y;
//        int lb = Sparrow.stage.height - _tileCount * _tileSize - 162.0f;
//        NSLog(@"newY: %f", newY);
//        if (newY <= 62 && lb <= newY) {
//            _content.y = newY;
//        }

    } else if (touches.count >= 2) {
        isPinched = YES;
        // two fingers touching -> rotate and scale
        SPTouch *touch1 = touches[0];
        SPTouch *touch2 = touches[1];
        
        SPPoint *touch1PrevPos = [touch1 previousLocationInSpace:_content.parent];
        SPPoint *touch1Pos = [touch1 locationInSpace:_content.parent];
        SPPoint *touch2PrevPos = [touch2 previousLocationInSpace:_content.parent];
        SPPoint *touch2Pos = [touch2 locationInSpace:_content.parent];
        
        SPPoint *prevVector = [touch1PrevPos subtractPoint:touch2PrevPos];
        SPPoint *vector = [touch1Pos subtractPoint:touch2Pos];
        
        // update pivot point based on previous center
        SPPoint *touch1PrevLocalPos = [touch1 previousLocationInSpace:_content];
        SPPoint *touch2PrevLocalPos = [touch2 previousLocationInSpace:_content];
        _content.pivotX = (touch1PrevLocalPos.x + touch2PrevLocalPos.x) * 0.5f;
        _content.pivotY = (touch1PrevLocalPos.y + touch2PrevLocalPos.y) * 0.5f;
        
        // update location based on the current center
        _content.x = (touch1Pos.x + touch2Pos.x) * 0.5f;
        _content.y = (touch1Pos.y + touch2Pos.y) * 0.5f;
        
        float sizeDiff = vector.length / prevVector.length;
        _content.scaleX = _content.scaleY = MAX(0.45f, _content.scaleX * sizeDiff);
    }
}

- (void)tapGrid:(SPTouch *)touchUp
{
    SPPoint *touchPosition = [touchUp locationInSpace:_gridContainer];
    // Get i, j of tile
    int i = floor(touchPosition.x / _tileSize);
    int j = floor(touchPosition.y / _tileSize);
    
    Tile *tile = [[_tiles objectAtIndex:i] objectAtIndex:j];
    if (_shipCommandBar) {
        [_shipCommandBar selectTile:tile];
    }
}


- (void)advanceJugglers:(SPEnterFrameEvent *)event
{
    [_shipJuggler advanceTime:event.passedTime];
}

- (void)doneSettingShips
{
    NSLog(@"Here");
    [self removeChild:_shipsTray];
    _shipsTray = nil;
    
    _shipCommandBar = [[ShipCommandBar alloc] init];
    _shipCommandBar.y = Sparrow.stage.height - 100.0f;
    _shipCommandBar.x = 0.0f;
    [self addChild:_shipCommandBar];
    
    for (Ship *ship in _myShips) {
        [ship positionedShip];
    }
    [_delegate sendTurn];
}

@end
