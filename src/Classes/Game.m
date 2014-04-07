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
#import "GameManager.h"
#import "ShipSegment.h"
#import "MenuViewController.h"


@interface Game () {
	bool isGrabbed;
    bool isPinched;
    bool shipGrabbed;
    float shipOffsetX;
    float shipOffsetY;
}


@property (nonatomic, strong) SPButton *doneSetupBtn;
@property (nonatomic, strong) SPButton *acceptReefBtn;
@property (nonatomic, strong) SPButton *rejectReefBtn;


@property (nonatomic, strong) Tile *cannonCollisionTile; // Tile which suffered from collision THIS turn.

@property (nonatomic, strong) MenuViewController *matchMakerController;

@property (nonatomic, strong) SPImage *myTurnImage;
@property (nonatomic, strong) SPImage *enemyTurnImage;


@end

static NSArray *startShipTypes = nil;

@implementation Game


- (id)init
{
    if ((self = [super init])) {
        _tileSize = 32.0f;
        _tileCount = 30;
        _myShips = [[NSMutableSet alloc] init];
        _enemyShips = [[NSMutableSet alloc] init];
        [self setupStage];
        [self presentMenu];
    }
    return self;
}

- (void)presentMenu
{
    if (!_matchMakerController) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        _matchMakerController = [[MenuViewController alloc] initWithGame:self];
        _matchMakerController.view.frame = CGRectMake(0.0, 0.0, screenHeight, screenWidth);
    }
    
    [Sparrow.currentController addChildViewController:_matchMakerController];
    [Sparrow.currentController.view addSubview:_matchMakerController.view];
}

- (void)dismissMenu
{
    [_matchMakerController dismissViewControllerAnimated:NO completion:nil];
    [_matchMakerController.view removeFromSuperview];
    [_matchMakerController removeFromParentViewController];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self presentMenu];
}

- (void)newGame
{
    [self clearMap];
    _currentStateType = StateTypeReefProposal;
    self.myTurn = YES;
    [self handleState:nil type:StateTypeReefProposal];
}

- (void)generateRandomReef
{
  int count = 0;
  int x0 = 3;
  int y0 = 10;
  while (count < 24){
	int x = arc4random_uniform(24);
	int y = arc4random_uniform(10);
	Tile *t = [self tileAtRow:(x0 + x) col:(y0 + y)];
	if (! t.reef){
	  [t setReef:YES];
	  count ++;
	}
  }
}

- (Tile *)tileAtRow:(int)row col:(int)col
{
    if (row < 0 || row > 29 || col < 0 || col > 29) {
        return nil;
    }
    return [[_tiles objectAtIndex:col] objectAtIndex:row];
}

- (void)acceptReef
{
    [self performedAction];
    [_acceptReefBtn setVisible:NO];
    [_rejectReefBtn setVisible:NO];
    [_shipCommandBar deselect];
}

- (void)rejectReef
{
    [self clearMap];
    _currentStateType = StateTypeReefProposal;
    [_rejectReefBtn setVisible:YES];
    [_acceptReefBtn setVisible:YES];
    [self generateRandomReef];
}

- (void)doneSetup
{
    [self performedAction];
    [_doneSetupBtn setVisible:NO];
}

//  stateType is my state.
- (void)handleState:(NSDictionary *)state type:(StateType)stateType
{
    _currentStateType = stateType;
    if (stateType == StateTypeReefAccepting) {
        [_rejectReefBtn setVisible:YES];
        [_acceptReefBtn setVisible:YES];
    } else if (stateType == StateTypeReefProposal) {
        [self generateRandomReef];
        [_rejectReefBtn setVisible:YES];
        [_acceptReefBtn setVisible:YES];
        return;
    } else if (stateType == StateTypeShipSetupLeft) {
        [self createShipsLeft:YES];
    } else if (stateType == StateTypeShipSetupRight) {
        [self loadState:state];
        [self createShipsLeft:NO];
    } else if (stateType == StateTypePlay) {
        [self loadState:state];
    }
}

- (void)receivedGame:(NSDictionary *)state
{
    if (!state) {
        NSLog(@"Received game without any state");
        [self presentMenu];
        return;
    }
    
    [self clearMap];
    NSString *myId = [GKLocalPlayer localPlayer].playerID;
    GKTurnBasedMatch *currentMatch = [[NKMatchHelper sharedInstance] currentMatch];
    if ([currentMatch.currentParticipant.playerID isEqualToString:myId]) {
        self.myTurn = YES;
    } else {
        self.myTurn = NO;
    }
    
    [self setupReefs:[state objectForKey:@"reef"]];
    
    if (_myTurn) {
        StateType opponentStateType = ((NSNumber *)[state objectForKey:@"stateType"]).intValue;
        StateType myNewStateType;
        NSLog(@"OpponentString: %ld", (long)opponentStateType);
        switch (opponentStateType) {
            case StateTypeReefProposal:
                myNewStateType = StateTypeReefAccepting;
                break;
            case StateTypeReefAccepting:
                myNewStateType = StateTypeShipSetupLeft;
                break;
            case StateTypeShipSetupLeft:
                myNewStateType = StateTypeShipSetupRight;
                break;
            case StateTypeShipSetupRight:
                myNewStateType = StateTypePlay;
                break;
                case StateTypePlay:
                myNewStateType = StateTypePlay;
                break;
            default:
                NSLog(@"Received game without the other player's info");
                [self presentMenu];
                return;
                break;
        }
        [self handleState:state type:myNewStateType];
    } else {
        [self loadState:state];
    }
}

- (void)loadState:(NSDictionary *)state
{
    // Remember, this can be called any time if it is not my turn, and only on play if it is my turn.
    NSLog(@"LoadingState: %@", state);
    NSString *myId = [GKLocalPlayer localPlayer].playerID;

    // Old stuff
    
    if (_cannonCollisionTile) {
        [_cannonCollisionTile displayCannonHit:NO];
        _cannonCollisionTile = nil;
    }
    
    // Load enemy ships
    NSArray *enemyShips;
    for (NSString *enemyId in [state allKeys]) {
        if (![enemyId isEqualToString:@"Mines"] && ![enemyId isEqualToString:@"notify"] && ![enemyId isEqualToString:myId] && ![enemyId isEqualToString:@"reef"] && ![enemyId isEqualToString:@"stateType"]) {
            enemyShips = [state objectForKey:enemyId];
            break;
        }
    }
    if (enemyShips) {
        [self setupEnemyShips:enemyShips];
    }
    
    
    NSArray *myShips = [state objectForKey:myId];
    [self setupMyShips:myShips];
    
    // Collision notify tile
    NSArray *notify = [state objectForKey:@"notify"];
    if (notify && [notify count] > 1) {
        NSInteger row = [[notify objectAtIndex:0] integerValue];
        NSInteger col = [[notify objectAtIndex:1] integerValue];
        Tile *tile = [[_tiles objectAtIndex:col] objectAtIndex:row];
        [tile displayCannonHit:YES];
    }
}

- (void)createShipsLeft:(BOOL)left
{
    _myShips = [[NSMutableSet alloc] init];
    for (int i = 0; i < [startShipTypes count]; i++) {
        NSNumber *shipType = [startShipTypes objectAtIndex:i];
        Ship *newShip = [[Ship alloc] initWithGame:self type:[shipType intValue]];
        if (newShip.shipType == BaseType) {
            newShip.baseRow = 19;
            if (left) {
                newShip.baseColumn = 0;
            } else {
                newShip.baseColumn = 29;
            }
        } else {
            newShip.baseRow = i + 10;
            if (left) {
                newShip.baseColumn = 1;
                newShip.dir = Right;
            } else {
                newShip.baseColumn = 28;
                newShip.dir = Left;
            }
        }
        [_myShips addObject:newShip];
        
        [_gridContainer addChild:newShip];
        [newShip positionedShip];
        [newShip updateLocation];
    }
    
    [_doneSetupBtn setVisible:YES];
}

- (void)clearMap
{
    [self dismissMenu];
    [_doneSetupBtn setVisible:NO];
    [_acceptReefBtn setVisible:NO];
    [_rejectReefBtn setVisible:NO];
    
    for (NSArray *column in _tiles) {
        for (Tile *tile in column) {
            [tile cleanTile];
        }
    }
    
    for (Ship *ship in _myShips) {
        [ship removeFromParent];
    }
    _myShips = nil;
    for (Ship *ship in _enemyShips) {
        [ship removeFromParent];
    }
    _enemyShips = nil;
    
    if(_shipCommandBar) {
        [_shipCommandBar deselect];
    }
    
    _currentStateType = StateTypeNone;
}

- (void)setupMyShips:(NSArray *)myShips
{
    for (Ship *ship in _myShips) {
        [ship removeFromParent];
    }
    
    _myShips = [[NSMutableSet alloc] init];
    BOOL isSunk;
    for (NSArray *shipAttrs in myShips) {
        isSunk = YES;
        Ship *newShip = [[Ship alloc] initWithGame:self type:(ShipType)([(NSNumber *)[shipAttrs objectAtIndex:3] intValue])];
        newShip.baseRow = ([(NSNumber *)[shipAttrs objectAtIndex:0] intValue]);
        newShip.baseColumn = ([(NSNumber *)[shipAttrs objectAtIndex:1] intValue]);
        newShip.dir = ([(NSNumber *)[shipAttrs objectAtIndex:2] intValue]);
        
        NSArray *health = [shipAttrs objectAtIndex:4];
        for (int i = 0; i < newShip.shipSegments.count; i++) {
            ShipSegment *segment = [newShip.shipSegments objectAtIndex:i];
            segment.health = ([(NSNumber *)[health objectAtIndex:i] intValue]);
            if (segment.health > 0) {
                isSunk = NO;
            }
        }
        
        [_myShips addObject:newShip];
        
        if (isSunk) {
            [newShip sinkShip];
        } else {
            [_myShips addObject:newShip];
            [_gridContainer addChild:newShip];
            [newShip positionedShip];
            [newShip updateLocation];
        }
    }
    
    for (Ship *ship in _myShips) {
        if (!ship.isSunk) {
            [ship setSurroundingTilesVisible];
        }
    }
}

- (void)setupEnemyShips:(NSArray *)enemyShips
{
    for (Ship *ship in _enemyShips) {
        [ship removeFromParent];
    }
    
    _enemyShips = [[NSMutableSet alloc] init];
    BOOL isSunk;
    for (NSArray *shipAttrs in enemyShips) {
        isSunk = YES;
        Ship *newShip = [[Ship alloc] initWithGame:self type:(ShipType)([(NSNumber *)[shipAttrs objectAtIndex:3] intValue])];
        newShip.baseRow = ([(NSNumber *)[shipAttrs objectAtIndex:0] intValue]);
        newShip.baseColumn = ([(NSNumber *)[shipAttrs objectAtIndex:1] intValue]);
        newShip.dir = ([(NSNumber *)[shipAttrs objectAtIndex:2] intValue]);
        NSArray *health = [shipAttrs objectAtIndex:4];
        if (health) {
            for (int i = 0; i < newShip.shipSegments.count; i++) {
                ShipSegment *segment = [newShip.shipSegments objectAtIndex:i];
                segment.health = ([(NSNumber *)[health objectAtIndex:i] intValue]);
                if (segment.health > 0) {
                    isSunk = NO;
                }
            }
        }
        
        [_enemyShips addObject:newShip];
        
        if (isSunk) {
            [newShip sinkShip];
        } else {
            [_enemyShips addObject:newShip];
            [newShip updateTilesOccupied];
            
            [_gridContainer addChild:newShip];
            [newShip setIsEnemyShip:YES];
            [newShip updateLocation];
        }
    }
    
    for (Ship *ship in _enemyShips) {
        if (!ship.isSunk) {
            for (ShipSegment *segment in ship.shipSegments) {
                [segment.tile fogOfWar:NO];
            }
        }
    }
}

- (void)setupReefs:(NSArray *)reefs
{
    if (!reefs) {
        return;
    }
    
    int row;
    int col;
    for (NSArray *reef in reefs) {
        row = ([(NSNumber *)[reef objectAtIndex:0] intValue]);
        col = ([(NSNumber *)[reef objectAtIndex:1] intValue]);
        [[[_tiles objectAtIndex:col] objectAtIndex:row] setReef:YES];;
    }
    
}

- (NSDictionary *)getDataDictWithMyID:(NSString *)myID opponentID:(NSString *)oppID
{
    NSMutableArray *myShips = [[NSMutableArray alloc] init];
    for (Ship *ship in _myShips) {
        
        NSMutableArray *health = [[NSMutableArray alloc] init];
        BOOL shouldHeal = NO;
        if (ship.shipType != BaseType && [ship isTouchingBase]) {
            shouldHeal = YES;
        }
        for (ShipSegment *segment in [ship.shipSegments reverseObjectEnumerator])
        {
            int segmentHealth = segment.health;
            if (shouldHeal && segmentHealth != 2) {
                shouldHeal = NO;
                segmentHealth = 2;
                NSLog(@"Healing a ship segment");
            }
            [health addObject:num(segmentHealth)];
        }
        
        NSArray *shipAttrs = [NSArray arrayWithObjects:num(ship.baseRow), num(ship.baseColumn), num(ship.dir), num(ship.shipType), [[health reverseObjectEnumerator] allObjects], nil];
        [myShips addObject:shipAttrs];
    }
    
    NSMutableArray *enemyShips = [[NSMutableArray alloc] init];
    for (Ship *ship in _enemyShips) {
        NSMutableArray *health = [[NSMutableArray alloc] init];
        for (ShipSegment *segment in ship.shipSegments) {
            [health addObject:num(segment.health)];
        }
        
        NSArray *shipAttrs = [NSArray arrayWithObjects:num(ship.baseRow), num(ship.baseColumn), num(ship.dir), num(ship.shipType), [NSArray arrayWithArray:health], nil];
        [enemyShips addObject:shipAttrs];
    }
    
    if (!oppID) {
        oppID = @"-1";
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithObjectsAndKeys:myShips, myID, enemyShips, oppID, nil];
    
    if (_cannonCollisionTile) {
        NSArray *notifyTile = [NSArray arrayWithObjects:num(_cannonCollisionTile.row), num(_cannonCollisionTile.col), nil];
        [result setObject:notifyTile forKey:@"notify"];
    }
    
    NSMutableArray *reefs = [[NSMutableArray alloc] init];
    for (NSArray *column in _tiles) {
        for (Tile *tile in column) {
            if (tile.reef) {
                NSArray *position = [NSArray arrayWithObjects:num(tile.row), num(tile.col), nil];
                [reefs addObject:position];
            }
        }
    }
    [result setObject:[NSArray arrayWithArray:reefs] forKey:@"reef"];
    
    [result setObject:num(_currentStateType) forKey:@"stateType"];
    
    return [NSDictionary dictionaryWithDictionary:result];
    
    
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

- (BOOL)checkVictoryWithMyID:(NSString *)myID
{
    //  Game just started.
    if (_enemyShips == nil || [_enemyShips count] == 0) {
        return NO;
    }
    
    for (Ship *ship in _enemyShips) {
        for (ShipSegment *segment in ship.shipSegments) {
            if (segment.health > 0) {
                return NO;
            }
        }
    }
    return YES;
}

- (void)performedAction
{
    self.myTurn = NO;
    [_delegate sendTurn];
}

- (void)notifyCannonCollision:(Tile *)tile
{
    _cannonCollisionTile = tile;
}

- (void)dealloc
{
    // release any resources here
    [Media releaseAtlas];
    [Media releaseSound];
}

- (void)setMyTurn:(BOOL)myTurn
{
    _myTurn = myTurn;
    [_myTurnImage setVisible:myTurn];
    [_enemyTurnImage setVisible:!myTurn];
}

- (void)setupStage
{
    
    //    [SPAudioEngine start];  // starts up the sound engine
    startShipTypes = @[num(Cruiser), num(Cruiser), num(Destroyer), num(Destroyer), num(Destroyer), num(Torpedo), num(Torpedo), num(Miner), num(Miner), num(Radar), num(BaseType)];
    
    
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
    
    
    _shipCommandBar = [[ShipCommandBar alloc] initWithGame:self];
    _shipCommandBar.y = Sparrow.stage.height - 100.0f;
    _shipCommandBar.x = 0.0f;
    [self addChild:_shipCommandBar];
    
    [_gridContainer addEventListener:@selector(scrollGrid:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    //  doneSetup button
    SPTexture *checkmarkButtonTexture = [SPTexture textureWithContentsOfFile:@"green_checkmark.png"];
    _doneSetupBtn = [[SPButton alloc] initWithUpState:checkmarkButtonTexture];
    _doneSetupBtn.x = (Sparrow.stage.width - _doneSetupBtn.width) / 2.0f;
    _doneSetupBtn.y = (_doneSetupBtn.height) * 2.0f;
    [self addChild:_doneSetupBtn];
    [_doneSetupBtn addEventListener:@selector(doneSetup) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [_doneSetupBtn setVisible:NO];
    
    //  acceptReef button
    _acceptReefBtn = [[SPButton alloc] initWithUpState:checkmarkButtonTexture];
    _acceptReefBtn.x = _doneSetupBtn.x - 2 * _acceptReefBtn.width;
    _acceptReefBtn.y = _doneSetupBtn.y;
    [self addChild:_acceptReefBtn];
    [_acceptReefBtn addEventListener:@selector(acceptReef) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [_acceptReefBtn setVisible:NO];
    
    //  rejectReef button
    SPTexture *rejectButtonTexture = [SPTexture textureWithContentsOfFile:@"red_cross.png"];
    _rejectReefBtn = [[SPButton alloc] initWithUpState:rejectButtonTexture];
    _rejectReefBtn.x = _doneSetupBtn.x + 2 * _acceptReefBtn.width;
    _rejectReefBtn.y = _doneSetupBtn.y;
    [self addChild:_rejectReefBtn];
    [_rejectReefBtn addEventListener:@selector(rejectReef) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [_rejectReefBtn setVisible:NO];
    
    // Turn notifier.
    _myTurnImage = [[SPImage alloc] initWithContentsOfFile:@"green_circle.png"];
    _enemyTurnImage = [[SPImage alloc] initWithContentsOfFile:@"grey_circle.png"];
    _myTurnImage.x = Sparrow.stage.width - _myTurnImage.width - 10;
    _myTurnImage.y = 10;
    _myTurnImage.width = 20;
    _myTurnImage.height = 20;
    _enemyTurnImage.x = Sparrow.stage.width - _enemyTurnImage.width - 10;
    _enemyTurnImage.y = 10;
    _enemyTurnImage.width = 20;
    _enemyTurnImage.height = 20;
    [self addChild:_myTurnImage];
    [self addChild:_enemyTurnImage];
    [_enemyTurnImage setVisible:NO];
    
    // Main Menu btn
    SPTexture *menuTexture = [[SPTexture alloc] initWithContentsOfFile:@"blue_panel.png"];
    SPButton *menu = [[SPButton alloc] initWithUpState:menuTexture text:@"Main Menu"];
    menu.x = -3;
    menu.y = -28;
    menu.height = 64;
    [menu addEventListener:@selector(presentMenu) atObject:self forType:SP_EVENT_TYPE_TRIGGERED];
    [self addChild:menu];
}

- (void)scrollGrid:(SPTouchEvent *)event
{
    NSArray *touches = [[event touchesWithTarget:_gridContainer andPhase:SPTouchPhaseMoved] allObjects];
    SPTouch *touchUp = [[event touchesWithTarget:self andPhase:SPTouchPhaseEnded] anyObject];
    
    
    
    if (touches.count == 0) {
        if (touchUp) {
            if (!isGrabbed && !isPinched) {
                [self tapGrid:touchUp];
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
    if (!tile.selectable) {
        if (tile.myShipSegment && !tile.myShipSegment.ship.isEnemyShip) {
            return;
        }
        if (tile.myShip && !tile.myShip.isEnemyShip) {
            return;
        }
    }
    
    
    if (_shipCommandBar && _myTurn) {
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
