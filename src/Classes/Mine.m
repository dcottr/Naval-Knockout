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
#import "ShipSegment.h"
@interface Mine ()

@property (nonatomic, strong) NSArray *triggerTiles;

@end

@implementation Mine

static SPTexture *mineTexture = nil;
- (id)initWithTile:(Tile *)tile
{
    if (!mineTexture) {
        mineTexture = [SPTexture textureWithContentsOfFile:@"mine.png"];
    }
    self = [super init];
    if (self) {
        _tile = tile;
        SPImage *image = [[SPImage alloc] initWithTexture:mineTexture];
        image.width = 32.0f;
        image.height = 32.0f;
        [self addChild:image];
    }
    return self;
}

- (void)explode:(ShipSegment *)segment
{
    [segment hitByMine];
    [_tile notifyEvent];
    [_tile removeMine];
}

@end
