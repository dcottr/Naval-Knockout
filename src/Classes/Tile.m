//
//  Tile.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-05.
//
//

#import "Tile.h"
#import "Game.h"
#import "Mine.h"

@interface Tile ()

@property (nonatomic, weak) Game * game;
@property (nonatomic, strong) SPQuad *selectableOverlay;

@property (nonatomic, strong) Mine *mine;

@property (nonatomic, strong) SPQuad *collisionOverlay;

@end

@implementation Tile

static SPTexture *waterTexture = nil;
static NSDictionary *reefPositions = nil;

- (id)initWithGame:(Game *)game row:(int)r column:(int)c
{
    if (!waterTexture) {
        waterTexture = [SPTexture textureWithContentsOfFile:@"watertile.jpeg"];
    }
	[self initReef];
    self = [super init];
    if (self) {
        _game = game;
        _row = r;
        _col = c;
	  // is this a reef?
	  if( [[reefPositions objectForKey:num(r)] containsObject:num(c)] ){
		_reef = YES;
	  }
        SPImage *image = [[SPImage alloc] initWithTexture:waterTexture];
        image.width = _game.tileSize;
        image.height = _game.tileSize;
        [self addChild:image];
    }
    return self;
}


- (void)setSelectable:(BOOL)selectable
{
    if (!_selectableOverlay) {
        _selectableOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize height:_game.tileSize color:0x00FF00];
        [self addChild:_selectableOverlay];
    }
    [_selectableOverlay setVisible:selectable];
}

- (void)performMineAction
{
    _mine = [[Mine alloc] initWithTile:self];
    _hasMine = YES;
    [self addChild:_mine];
}

- (void)displayCannonHit:(BOOL)display
{
    if (!_collisionOverlay) {
        _collisionOverlay = [[SPQuad alloc] initWithWidth:_game.tileSize height:_game.tileSize color:0xff0000];
        [self addChild:_collisionOverlay];
    }
    [_collisionOverlay setVisible:display];
}

- (void)performCannonAction
{
    [self displayCannonHit:YES];
    [_game notifyCannonCollision:self];
}

- (void)initReef
{
  if (!reefPositions){
	reefPositions = @{num(6):@[num(10),num(11)], // reef space occupies rows 3 - 27, cols 10-20
					  num(7):@[num(12),num(13)],
					  num(8):@[num(10),num(11),num(12)],
					  num(9):@[num(20)],
					  num(10):@[num(19),num(18)],
					  num(11):@[num(17),num(16)],
					  num(12):@[num(13),num(14),num(15),num(16)],
					  num(14):@[num(13),num(14),num(15),num(16)],
					  num(16):@[num(11)],
					  num(17):@[num(10)],
					  num(24):@[num(19),num(20)],
					  };
  }
}

// Yellow: 0xffff00

@end
