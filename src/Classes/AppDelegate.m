//
//  AppDelegate.m
//  AppScaffold
//

#import "AppDelegate.h"
#import "Game.h"

// --- c functions ---

void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}

// ---

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
    
    _viewController = [[SPViewController alloc] init];
    
    // Enable some common settings here:
    //
    // _viewController.showStats = YES;
    // _viewController.multitouchEnabled = YES;
    // _viewController.preferredFramesPerSecond = 60;
    
    [_viewController startWithRoot:[Game class] supportHighResolutions:YES doubleOnPad:YES];
    
    [_window setRootViewController:_viewController];
    [_window makeKeyAndVisible];
    _viewController.multitouchEnabled = YES;
    
    return YES;
}

@end
