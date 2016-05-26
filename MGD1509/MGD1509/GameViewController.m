//
//  GameViewController.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/1/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "SplashScene.h"
@import AVFoundation;

@interface GameViewController()

@property (nonatomic) AVAudioPlayer* backgroundMusicPlayer;

@end

//@implementation SKScene (Unarchive)
//
//+ (instancetype)unarchiveFromFile:(NSString *)file {
//    /* Retrieve scene file path from the application bundle */
//    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
//    /* Unarchive the file to an SKScene object */
//    NSData *data = [NSData dataWithContentsOfFile:nodePath
//                                          options:NSDataReadingMappedIfSafe
//                                            error:nil];
//    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    [arch setClass:self forClassName:@"SKScene"];
//    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
//    [arch finishDecoding];
//    
//    return scene;
//}
//
//@end

@implementation GameViewController

- (void) viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	
	// Configure Splash Scene
	SKView *skView = (SKView*) self.view;
	if (!skView.scene) {
		skView.showsFPS = NO;
		skView.showsNodeCount = NO;
		
		// Present Splash Scene
		SKScene *splashScene = [SplashScene sceneWithSize: skView.bounds.size];
		splashScene.scaleMode = SKSceneScaleModeAspectFill;
		[skView presentScene: splashScene];
	}
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Background music
	[self playBackgroundMusic];
	
}

- (void) playBackgroundMusic {
	NSError* error;
	NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background" withExtension:@"wav"];
	self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
	self.backgroundMusicPlayer.numberOfLoops = -1;
	[self.backgroundMusicPlayer prepareToPlay];
	[self.backgroundMusicPlayer setVolume:0.4];
	[self.backgroundMusicPlayer play];
}

- (void) pauseBackgroundMusic {
	[self.backgroundMusicPlayer pause];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

//- (NSInteger)supportedInterfaceOrientations
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    } else {
//        return UIInterfaceOrientationMaskAll;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



@end
