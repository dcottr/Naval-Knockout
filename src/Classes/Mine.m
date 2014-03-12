//
//  Mine.m
//  Naval Knockout
//
//  Created by David Cottrell on 2014-03-12.
//
//

#import "Mine.h"
#import "Tile.h"

@interface Mine ()

@property (nonatomic, weak) Tile *tile;

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
//        image.width = _game.tileSize;
//        image.height = _game.tileSize;
        [self addChild:image];
    }
    return self;
}


@end
