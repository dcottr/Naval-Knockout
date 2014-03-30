//
//  MatchMakerViewController.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-09.
//
//

#import "MenuViewController.h"
#import "NKMatchHelper.h"
#import "GameManagerViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController


- (id)init
{
  self = [super initWithNibName:@"MenuViewController" bundle:nil];
  if (self) {
      //
  }
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  NKMatchHelper *helper = [NKMatchHelper sharedInstance];
  helper.menuViewController = self;
  helper.delegate = [[GameManagerViewController alloc] init];
  [[NKMatchHelper sharedInstance] authenticateLocalPlayer];
//  [[NKMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadGame:(id)sender
{
  [[NKMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

@end