//
//  ShipsTray.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "ShipsTray.h"


static SPTexture *trayBarTexture = nil;

@implementation ShipsTray


- (id)init
{
    if (!trayBarTexture)
        trayBarTexture = [SPTexture textureWithContentsOfFile:@"Glossy05.png"];

    self = [super init];
    if (self) {
        SPImage *trayBar = [[SPImage alloc] initWithTexture:trayBarTexture];
        trayBar.width = Sparrow.stage.width;
        trayBar.height = 100.0f;
        [self addChild:trayBar];
    }
    return self;
}
@end
