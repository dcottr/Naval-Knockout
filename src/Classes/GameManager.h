//
//  GameManagerViewController.h
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-09.
//
//

#import <UIKit/UIKit.h>
#import "NKMatchHelper.h"

@interface GameManager : NSObject <NKMatchHelperDelegate>


- (void)sendTurn;
- (id)initWithGame:(Game *)game;

@end
