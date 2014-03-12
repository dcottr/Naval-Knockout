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

@end

@implementation Tile

static SPTexture *waterTexture = nil;
- (id)initWithGame:(Game *)game row:(int)r column:(int)c
{
    if (!waterTexture) {
        waterTexture = [SPTexture textureWithContentsOfFile:@"watertile.jpeg"];
    }
    self = [super init];
    if (self) {
        _game = game;
        _row = r;
        _col = c;
        
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
    [self addChild:_mine];
}

@end
