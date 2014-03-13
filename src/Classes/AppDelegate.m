//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
/// Comment this out
#import "Game.h"
///
#import "MatchMakerViewController.h"

// --- c functions ---

void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}

// ---
@interface AppDelegate ()

@property (nonatomic, strong) MatchMakerViewController *matchMaker;
@end

@implementation AppDelegate
{
    SPViewController *_viewController;
    UIWindow *_window;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&onUncaughtException);
    
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    _window = [[UIWindow alloc] initWithFrame:screenBounds];

    //     Comment out from here:
    /*
     _viewController = [[SPViewController alloc] init];
    
     _viewController.showStats = YES;
     _viewController.multitouchEnabled = YES;
     _viewController.preferredFramesPerSecond = 60;
    
    [_viewController startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
    
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];
    _viewController.multitouchEnabled = YES;
    */

	_matchMaker = [[MatchMakerViewController alloc] init];
  [_window setRootViewController:_matchMaker];
  [_window makeKeyAndVisible];
  
    return YES;
}

- (void)setGame:(Game *)game
{
    _game = game;
    NSNotification *notification = [[NSNotification alloc] initWithName:@"GameInitialized" object:self userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
