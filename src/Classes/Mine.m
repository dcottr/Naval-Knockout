//
//  Mine.m
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-12.
//
//

#import "Mine.h"
#import "Tile.h"
#import "Game.h"
@interface Mine ()

@property (nonatomic, strong) NSArray *triggerTiles;

@end

@implementation Mine

static SPTexture *mineTexture = nil;
- (id)initWithTile:(Tile *)tile
{
    if (!mineTexture) {
        mineTexture = [SPTexture textureWithContentsOfFile:@"ship_small_body.png"];
    }
    self = [super init];
    if (self) {
        _tile = tile;
        SPImage *image = [[SPImage alloc] initWithTexture:mineTexture];
        image.width = 32.0f;
        image.width = 32.0f;
        [self addChild:image];
        [self setup];
//        [tile addMine:self];
    }
    return self;
}

- (void)setup
{
    int row = _tile.row;
    int col = _tile.col;
    Game *game = (Game *)Sparrow.root;
    _tile = [game tileAtRow:row col:(col + 1)];
    NSMutableArray *triggerTiles;
    if (_tile) {
        [triggerTiles addObject:_tile];
        [_tile addMineTrigger:self];
    }
    _tile = [game tileAtRow:row col:(col - 1)];
    if (_tile) {
        [triggerTiles addObject:_tile];
        [_tile addMineTrigger:self];
    }
    _tile = [game tileAtRow:(row + 1) col:col];
    if (_tile) {
        [triggerTiles addObject:_tile];
        [_tile addMineTrigger:self];
    }
    _tile = [game tileAtRow:(row - 1) col:col];
    if (_tile) {
        [triggerTiles addObject:_tile];
        [_tile addMineTrigger:self];
    }
    _triggerTiles = [NSArray arrayWithArray:triggerTiles];
}


@end
