//
//  ShipCommandBar.m
//  Scaffold
//
//  Created by David Cottrell on 2014-03-03.
//
//

#import "ShipCommandBar.h"

@interface ShipCommandBar ()

@property (nonatomic, strong) SPImage *commandBar;

@end

@implementation ShipCommandBar

static SPTexture *commandBarTexture = nil;

- (id)init
{
    if (!commandBarTexture)
        commandBarTexture = [SPTexture textureWithContentsOfFile:@"Glossy08.png"];

    self = [super init];
    if (self) {
        _commandBar = [[SPImage alloc] initWithTexture:commandBarTexture];
        _commandBar.width = Sparrow.stage.width;
        _commandBar.height = 100.0f;
        [self addChild:_commandBar];

    }
    return self;
}

- (void)setSelected:(Ship *)ship
{
    
}


@end
