//
//  MatchMakerViewController.m
//  Naval Knockout
//
//  Created by ivanfer on 2014-03-09.
//
//

#import "MatchMakerViewController.h"
#import "NKMatchHelper.h"

@interface MatchMakerViewController ()

@end

@implementation MatchMakerViewController


- (id)init
{
  self = [super initWithNibName:@"MatchMakerViewController" bundle:nil];
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
  helper.presentingViewController = self;
  [[NKMatchHelper sharedInstance] authenticateLocalPlayer];
//  [[NKMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newGame:(id)sender
{
  
}
- (IBAction)loadGame:(id)sender
{
  [[NKMatchHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:self];
}

@end
