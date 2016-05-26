//
//  GameScene.m
//  MGD1509
//
//  Created by Alex Hardtke on 9/1/15.
//  Copyright (c) 2015 Alex Hardtke. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"
#import "GameViewController.h"
#import "Level.h"
#import "GameKitHelper.h"
@import AVFoundation;

@interface GameScene() <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode *player, *asteroid1, *asteroid2, *asteroid3, *asteroid4, *asteroid5, *asteroid6, *asteroid7, *laserPlayer, *laserEnemy, *pauseButton;
@property (nonatomic) NSTimeInterval spawnInterval;
@property (nonatomic) NSTimeInterval updateInterval;
@property (nonatomic) SKLabelNode *scoreLabel, *healthLabel;
@property (nonatomic) CGSize screenSize;
@property (nonatomic) int score;
@property (nonatomic) int playerHealth;
@property (nonatomic) BOOL isPaused;
@property (nonatomic) SKTextureAtlas *spriteTextureAtlas;


@end

// Physics Bodies Categories
static const uint32_t laserCategory = 0x1 << 0;
static const uint32_t enemyCategory = 0x1 << 1;
static const uint32_t asteroidCategory = 0x1 << 2;
static const uint32_t enemyLaserCategory = 0x1 << 3;
static const uint32_t playerCategory = 0x1 << 4;

@implementation GameScene
{
	// Setup
	PFUser *currentUser;
	SaveData *saveData;
	NSArray *_explosionFrames;
	NSString *fileName;
	NSMutableArray *enemiesArray;
	
	// End game
	BOOL gameIsOver;
	BOOL levelIsCompleted;
	
	// Prize vars
	SKLabelNode *title, *label, *ok;
	SKSpriteNode *prizeSprite, *prizeBackground;
	BOOL isAwardingPrize;
}


- (id)initWithSize:(CGSize)size withFile:(NSString*)file
{
	
	if (self = [super initWithSize:size]) {
		
		NSLog(@"file = %@", file);
		
		currentUser = [PFUser currentUser];
		
		
		// Get Level File
		if (file != nil) {
			fileName = file;
			
			// Load Level
			self.level = [[Level alloc] initWithFile:fileName];
		}
		
		// Query SaveData
		PFQuery *query = [SaveData query];
		
		[query whereKey:@"user" equalTo:currentUser];
		[query whereKeyExists:@"objectId"];
		//[query whereKey:@"objectId" equalTo:@"Cgp1apa4cb"];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (!error) {
				saveData = [objects firstObject];
				NSLog(@"CareerScore: %d", saveData.careerScore);
			}
		}];
		
		// Set background
		self.backgroundColor = [SKColor blackColor];
		
		// Set new level defaults
		_spriteTextureAtlas = [self textureAtlasNamed:@"sprites"];
		self.score = 0;
		self.playerHealth = 5;
		enemiesArray = [NSMutableArray array];
		_screenSize = size;
		
		// Set BOOL flags
		_isPaused = NO;
		gameIsOver = NO;
		isAwardingPrize = NO;
		
		// Setup HUD
		[self setupHUD];
		[self setupExplosion];
		[self setupPlayer];
		[self setupAsteroids];
		
		// Set physics for scene
		self.physicsWorld.gravity = CGVectorMake(0, 0);
		self.physicsWorld.contactDelegate = self;
		
		// Log scene info
		NSLog(@"Screen Size: %@", NSStringFromCGSize(_screenSize));
		NSLog(@"Current Level: %d", self.level.levelNumber);
		
	}
	return self;
}





#pragma Setup Methods

// Sets up the HUD (Score Label and Pause Button)
- (void) setupHUD
{
	// Score Label
	NSString *scoreStr = [NSString stringWithFormat:@"Score: %d", self.score];
	self.scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	self.scoreLabel.text = scoreStr;
	self.scoreLabel.fontColor = [SKColor yellowColor];
	self.scoreLabel.fontSize = [self convertValue:20];
	self.scoreLabel.position = CGPointMake(self.frame.size.width/10, self.frame.size.height/20);
	[self addChild:self.scoreLabel];
	
	// Health label
	if (self.level.levelNumber == 11) {
		NSString *healthStr = [NSString stringWithFormat:@"Health: %d", self.playerHealth];
		self.healthLabel = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
		self.healthLabel.text = healthStr;
		self.healthLabel.fontColor = [SKColor greenColor];
		self.healthLabel.fontSize = [self convertValue:20];
		self.healthLabel.position = CGPointMake(self.scoreLabel.position.x + [self convertValue:80], self.frame.size.height / 20);
		[self addChild:self.healthLabel];
	}
	
	// Pause Button
	self.pauseButton = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"pause"]];
	self.pauseButton.name = @"pauseButton";
	self.pauseButton.position = CGPointMake(self.frame.size.width * .05, self.frame.size.height - [self convertValue:20]);
	[self addChild:self.pauseButton];
	
}

// Sets up the Player
- (void) setupPlayer
{
	
	self.player = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:[PlayerData sharedPlayerData].shipName]];
	self.player.name = @"player";
	self.player.position = CGPointMake(self.frame.size.width / 2, self.player.size.height / 2 + [self convertValue:5]);
	if (self.level.levelNumber == 11) {
		self.player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.player.size.width / 2, self.player.size.height / 2)];
		self.player.physicsBody.dynamic = YES;
		self.player.physicsBody.categoryBitMask = playerCategory;
		self.player.physicsBody.contactTestBitMask = enemyLaserCategory;
		self.player.physicsBody.collisionBitMask = 0;
		self.player.physicsBody.affectedByGravity = NO;
	}
	[self addChild:self.player];
	
}

// Sets up the Asteroids
- (void)setupAsteroids
{
	
	// Set asteroids
	self.asteroid1 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid1"]];
	self.asteroid1.name = @"asteroid1";
	self.asteroid1.position = CGPointMake(self.frame.size.width / 6, self.size.height * .20);
	[self.asteroid1 setScale:1.4];
	self.asteroid1.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid1.size.width / 20];
	self.asteroid1.physicsBody.dynamic = YES;
	self.asteroid1.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid1.physicsBody.contactTestBitMask = laserCategory| enemyLaserCategory;
	self.asteroid1.physicsBody.collisionBitMask = 0;
	self.asteroid1.physicsBody.affectedByGravity = NO;
	
	self.asteroid2 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid2"]];
	self.asteroid2.name = @"asteroid2";
	self.asteroid2.position = CGPointMake(self.frame.size.width / 2.5, self.size.height * .35);
	self.asteroid2.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid2.size.width / 20];
	[self.asteroid2 setScale:1.32];
	self.asteroid2.physicsBody.dynamic = YES;
	self.asteroid2.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid2.physicsBody.contactTestBitMask = laserCategory| enemyLaserCategory;
	self.asteroid2.physicsBody.collisionBitMask = 0;
	self.asteroid2.physicsBody.affectedByGravity = NO;
	
	self.asteroid3 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid3"]];
	self.asteroid3.name = @"asteroid3";
	self.asteroid3.position = CGPointMake(self.frame.size.width / 1.5, self.size.height * .35);
	self.asteroid3.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid3.size.width / 20];
	[self.asteroid3 setScale:1.42];
	self.asteroid3.physicsBody.dynamic = YES;
	self.asteroid3.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid3.physicsBody.contactTestBitMask = laserCategory| enemyLaserCategory;
	self.asteroid3.physicsBody.collisionBitMask = 0;
	self.asteroid3.physicsBody.affectedByGravity = NO;
	
	self.asteroid4 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid4"]];
	self.asteroid4.name = @"asteroid4";
	self.asteroid4.position = CGPointMake(self.frame.size.width / 1.2, self.size.height * .20);
	self.asteroid4.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid4.size.width / 20];
	[self.asteroid4 setScale:1.36];
	self.asteroid4.physicsBody.dynamic = YES;
	self.asteroid4.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid4.physicsBody.contactTestBitMask = laserCategory| enemyLaserCategory;
	self.asteroid4.physicsBody.collisionBitMask = 0;
	self.asteroid4.physicsBody.affectedByGravity = NO;
	
	self.asteroid5 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid1"]];
	self.asteroid5.name = @"asteroid5";
	self.asteroid5.position = CGPointMake(self.frame.size.width * .35, self.size.height * .75);
	self.asteroid5.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid4.size.width / 20];
	[self.asteroid5 setScale:1.53];
	self.asteroid5.physicsBody.dynamic = YES;
	self.asteroid5.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid5.physicsBody.contactTestBitMask = laserCategory|enemyLaserCategory;
	self.asteroid5.physicsBody.collisionBitMask = 0;
	self.asteroid5.physicsBody.affectedByGravity = NO;
	
	self.asteroid6 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid2"]];
	self.asteroid6.name = @"asteroid6";
	self.asteroid6.position = CGPointMake(self.frame.size.width * .50, self.size.height * .70);
	self.asteroid6.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid4.size.width / 20];
	[self.asteroid6 setScale:1.52];
	self.asteroid6.physicsBody.dynamic = YES;
	self.asteroid6.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid6.physicsBody.contactTestBitMask = laserCategory|enemyLaserCategory;
	self.asteroid6.physicsBody.collisionBitMask = 0;
	self.asteroid6.physicsBody.affectedByGravity = NO;
	
	self.asteroid7 = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:@"asteroid3"]];
	self.asteroid7.name = @"asteroid7";
	self.asteroid7.position = CGPointMake(self.frame.size.width * .65, self.size.height * .75);
	self.asteroid7.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:self.asteroid4.size.width / 20];
	[self.asteroid7 setScale:1.54];
	self.asteroid7.physicsBody.dynamic = YES;
	self.asteroid7.physicsBody.categoryBitMask = asteroidCategory;
	self.asteroid7.physicsBody.contactTestBitMask = laserCategory|enemyLaserCategory;
	self.asteroid7.physicsBody.collisionBitMask = 0;
	self.asteroid7.physicsBody.affectedByGravity = NO;
	
	if (self.level.totalAsteroids == 4) {
		[self addChild: self.asteroid1];
		[self addChild: self.asteroid2];
		[self addChild: self.asteroid3];
		[self addChild: self.asteroid4];
	}
	
	if (self.level.totalAsteroids == 5) {
		[self addChild: self.asteroid1];
		[self addChild: self.asteroid2];
		[self addChild: self.asteroid3];
		[self addChild: self.asteroid4];
		[self addChild: self.asteroid6];
	}
	
	if (self.level.totalAsteroids == 6) {
		[self addChild: self.asteroid1];
		[self addChild: self.asteroid2];
		[self addChild: self.asteroid3];
		[self addChild: self.asteroid4];
		[self addChild: self.asteroid5];
		[self addChild: self.asteroid7];
	}
	
	if (self.level.totalAsteroids == 7) {
		[self addChild: self.asteroid1];
		[self addChild: self.asteroid2];
		[self addChild: self.asteroid3];
		[self addChild: self.asteroid4];
		[self addChild: self.asteroid5];
		[self addChild: self.asteroid6];
		[self addChild: self.asteroid7];
	}
	
}

// Sets up a new Enemy every second (Called from update:)
- (void)setupEnemies
{
	
	// Get a random enemy (1 of 4 possible)
	int randomEnemy = 1 + arc4random() % (4 - 1);
	
	SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:[NSString stringWithFormat:@"enemy%d", randomEnemy]]];
	
	// Make this enemy spawn in a random location at the top of the scene
	int enemyWidth = enemy.size.width/2;
	int frameWidth = self.frame.size.width;
	int leftMax = enemyWidth;
	int rightMax = frameWidth - enemyWidth;
	int randomPos = (arc4random() % (rightMax - leftMax)) + enemyWidth;
	
	enemy.position = CGPointMake(randomPos, frameWidth + enemyWidth);
	
	// Set enemy's physics body
	enemy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemy.size];
	enemy.physicsBody.dynamic = NO;
	enemy.physicsBody.categoryBitMask = enemyCategory;
	enemy.physicsBody.contactTestBitMask = laserCategory;
	enemy.physicsBody.collisionBitMask = 0;
	
	// Add enemy to scene
	[self addChild:enemy];
	
	
	// *** PUT ENEMY INTO ACTION ***
	// Set a random speed based on this level's speed settings
	int slowest = self.level.enemySpeedMin;
	int fastest = self.level.enemySpeedMax;
	int randomSpeed = (arc4random() % (fastest - slowest)) + slowest;
	
	// The player loses the game if the enemy crosses the bottom of the screen, so make a Transition to GameOverScene if that happens
	SKAction *startEnemy = [SKAction moveTo:CGPointMake(randomPos, -enemyWidth) duration:randomSpeed];
	SKAction *endEnemy = [SKAction removeFromParent];
	SKAction *loseEnemy = [SKAction runBlock:^{
		// The player lost, so the playerData will not change. Just save the game.
		[self saveGame];
		
		// See if the player just lost level 1 - there is an achievement for that
		if (self.level.levelNumber == 1) {
			[[GameKitHelper sharedInstance] updateAchievements:1 win:NO health:5 score:0];
		}
		
		SKTransition *gameOverTrans = [SKTransition flipVerticalWithDuration:0.5];
		SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size wonGame:NO filename:fileName];
		[self.view presentScene:gameOverScene transition:gameOverTrans];
	}];
	
	SKAction *enemyAction = [SKAction sequence:@[startEnemy, loseEnemy, endEnemy]];
	[enemy runAction:enemyAction];
	
	[enemiesArray addObject:enemy];
	
	if (!gameIsOver && self.level.levelNumber == 11) {
		[self fireEnemyLaser:enemy];
	}
	
}

// Sets up the Explosion animation
- (void)setupExplosion
{
	
	NSMutableArray *explosionFrames = [NSMutableArray array];
	SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"Explosion"];
	int totalImages = explosionAtlas.textureNames.count;
	for (int i=1; i <= totalImages; i++) {
		NSString *textureStr = [NSString stringWithFormat:@"explosion%d", i];
		SKTexture *texture = [explosionAtlas textureNamed:textureStr];
		[explosionFrames addObject:texture];
	}
	_explosionFrames = explosionFrames;
	
}




#pragma Update Method

// Updates every second
-(void)update:(NSTimeInterval)currentTime
{
	
	/* Called before each frame is rendered */
	// lastUpdate is the last time this method was called.
	CFTimeInterval lastUpdate = currentTime - self.updateInterval;
	// self.updateInterval should be set to the currentTime because the update: method is being called right now
	self.updateInterval = currentTime;
	// If the lastUpdate was more than 1 second ago, it's time to update it
	if (lastUpdate > 1) {
		// If it's been more than 1 second, update
		lastUpdate = 1.0 / 60.0; // Seconds
		self.updateInterval = currentTime;
	}
	
	// Increase the spawnInterval (which was set to 0 the last time this method was called) by the lastUpdate (which is 1 second)
	self.spawnInterval += lastUpdate;
	
	// If spawnInterval is more than 1, reset it and add an enemy
	if (self.spawnInterval > 1) {
		// Reset it to 0
		self.spawnInterval = 0;
		// If the game is currently flagged as being over...
		if (gameIsOver) {
			// Remove all of the enemies in enemiesArray from the screen and remove its actions to make them stop moving
			for (SKSpriteNode *enemy in enemiesArray) {
				[enemy removeAllActions];
			}
		}
		// If the game is not over... it's time to setup another enemy because it's been 1 second
		if (!gameIsOver) {
			[self setupEnemies];
		}
	}
}






#pragma Size Conversion Methods

// Converts a number value based on whether the device is an iPad or iPhone (multiplies by 2 for iPad)
- (float) convertValue:(float)value
{
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		return value * 2;
	} else {
		return value;
	}
}

// Returns the appropriate SKTextureAtlas depending on whether or not the device is an iPad or iPhone
- (SKTextureAtlas *) textureAtlasNamed:(NSString *)name
{
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		// Phone
		name = name;
	} else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// Pad
		name = [NSString stringWithFormat:@"%@-ipad", name];
	}
	
	SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:name];
	
	return textureAtlas;
}






#pragma Pause Game Method

// Called when the pause button has been pressed. It sets self.view to paused.
- (void) pauseSelected
{
	
	if (_isPaused == YES) {
		self.view.paused = YES;
	} else if (_isPaused == NO) {
		self.view.paused = NO;
	}
	
}






#pragma Touch Event Method

// Called the the user touches the screen
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
	
	// Get the touch, where the touch happened, and the node itself.
	UITouch* touch = [touches anyObject];
	CGPoint location = [touch locationInNode:self];
	SKNode *node = [self nodeAtPoint:location];
	
	
	
	// If the pause button is pressed, set the isPaused flag and call pauseSelected: method.
	if ([node.name isEqualToString:@"pauseButton"]) {
		if (_isPaused == NO) {
			
			// The user paused the game
			_isPaused = YES;
			NSLog(@"PAUSE");
			
			[self pauseSelected];
			
		} else if (_isPaused == YES) {
			
			// The user has resumed the game
			_isPaused = NO;
			NSLog(@"RESUME");
			
			[self pauseSelected];
		}
		return;
	}
	
	// If the game is over and there is a ship or laser being awarded...
	if (gameIsOver && isAwardingPrize) {
		// The player might have won a reward after completing the level, and an SKLabelNode with "OK" will appear...
		if ([node.name isEqualToString:@"ok"]) {
			// Set isAwardingPrize flag back to NO
			isAwardingPrize = NO;
			// So dismiss this and send them to the GameOverScene
			SKTransition *gameOverTrans = [SKTransition moveInWithDirection:SKTransitionDirectionDown duration:0.5];
			SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size wonGame:YES filename:fileName];
			[self.view presentScene:gameOverScene transition:gameOverTrans];
		}
	}
	
	// If the game is NOT paused
	// And the game is NOT over
	// And the user is NOT pressing the pause button...
	// FIRE A LASER!
	if (_isPaused == NO && !gameIsOver && ![node.name isEqualToString:@"pause"]) {
		
		// Play laser sound
		[self playSfx:@"laser10"];
		
		
		// Set up laser position and physics body
		SKSpriteNode *laser = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:[PlayerData sharedPlayerData].laserName]];
		laser.position = self.player.position;
		laser.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:laser.size.width/2];
		laser.physicsBody.dynamic = YES;
		laser.physicsBody.categoryBitMask = laserCategory;
		laser.physicsBody.contactTestBitMask = enemyCategory;
		laser.physicsBody.collisionBitMask = 0;
		laser.physicsBody.usesPreciseCollisionDetection = YES;
		
		// Change the angle of the laser so that it points to the target
		float ax = location.x - laser.position.x;
		float ay = location.y - laser.position.y;
		double angle = atan2(ay, ax);
		laser.zRotation = angle;
		
		// Determine the path of the laser relative to where the user touched the screen.
		CGPoint pointA = location;
		CGPoint pointB = laser.position;
		CGPoint path = CGPointMake(pointA.x - pointB.x, pointA.y - pointB.y);
		
		// If the user selected below the player ship's position, return without firing
		if (path.y <= 0) {
			return;
		}
		
		// Add laser to parent
		[self addChild:laser];
		
		
		
		// Calculate the hypotenuse of the triangle that makes up the shot
		float hypotenuse = sqrtf(path.x * path.x + path.y * path.y);
		CGPoint direction = CGPointMake(path.x / hypotenuse, path.y / hypotenuse);
		
		// Calculate the MAX distance the laser should travel if it misses a target (should go off-screen)
		CGPoint shotDistance = CGPointMake(direction.x * 2000, direction.y * 2000);
		
		// Combine the shot distance with the starting position of the laser
		CGPoint shotFinal = CGPointMake(shotDistance.x + laser.position.x, shotDistance.y + laser.position.y);
		
		// Set the speed of the laser
		float laserSpeed = self.size.width / (_screenSize.height);
		
		// Now we can start the actions for firing the laser and removeFromParent when it leaves the screen
		SKAction *laserStart = [SKAction moveTo:shotFinal duration:laserSpeed];
		SKAction *laserEnd = [SKAction removeFromParent];
		SKAction *laserAction = [SKAction sequence:@[laserStart, laserEnd]];
		[laser runAction:laserAction];
		
	}
	

}

- (void)fireEnemyLaser:(SKSpriteNode*)enemy {
	
	// Make the enemy laser different than the player's laser color
	NSString *enemyLaserName;
	if ([[PlayerData sharedPlayerData].laserName isEqualToString:@"blueLaser"]) {
		enemyLaserName = @"redLaser";
	} else if ([[PlayerData sharedPlayerData].laserName isEqualToString:@"greenLaser"]) {
		enemyLaserName = @"blueLaser";
	} else if ([[PlayerData sharedPlayerData].laserName isEqualToString:@"redLaser"]) {
		enemyLaserName = @"greenLaser";
	}
	
	// Play laser sound
	[self playSfx:@"laser10"];
	
	// Set up laser position and physics body
	SKSpriteNode *laser = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:enemyLaserName]];
	laser.position = enemy.position;
	laser.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:laser.size.width/2];
	laser.physicsBody.dynamic = YES;
	laser.physicsBody.categoryBitMask = enemyLaserCategory;
	laser.physicsBody.contactTestBitMask = playerCategory;
	laser.physicsBody.collisionBitMask = 0;
	laser.physicsBody.usesPreciseCollisionDetection = YES;
	
	// Change the angle of the laser so that it points to the target
	laser.zRotation = M_PI_2;
	
	[self addChild:laser];
	
	// Set the speed of the laser
	float laserSpeed = self.size.width / (_screenSize.height);
	
	// Now we can start the actions for firing the laser and removeFromParent when it leaves the screen
	SKAction *laserStart = [SKAction moveTo:CGPointMake(enemy.position.x, -laser.size.height) duration:laserSpeed];
	SKAction *laserEnd = [SKAction removeFromParent];
	SKAction *laserAction = [SKAction sequence:@[laserStart, laserEnd]];
	[laser runAction:laserAction];
	
}

// Creates an explosion wherever the laser node hits an asteroid or enemy.
- (void) createExplosion:(SKSpriteNode*)explosion
{
	// Start the texture with the first of the _explosionFrames we already set up.
	SKTexture *texture = _explosionFrames[0];
	SKSpriteNode *explosionNode = [SKSpriteNode spriteNodeWithTexture:texture];
	explosionNode.position = CGPointMake(explosion.position.x, explosion.position.y);
	[self addChild:explosionNode];
	
	// Animate it.
	SKAction *explodeAction = [SKAction animateWithTextures:_explosionFrames timePerFrame:0.1f resize:NO restore:YES];
	SKAction *explodeDoneAction = [SKAction removeFromParent];
	[explosionNode runAction:[SKAction sequence:@[explodeAction, explodeDoneAction]]];
	return;
}

// Used for playing the various sound effects.
- (void)playSfx:(NSString*)soundFileName
{
	
	// Play the sound using SKAction. Append the ".wav" to the soundFileName first.
	NSString* soundName = [NSString stringWithFormat:@"%@.wav", soundFileName];
	SKAction* playSound = [SKAction playSoundFileNamed:soundName waitForCompletion:NO];
	[self runAction:playSound];
	
}






#pragma Collision Methods

// Collision detection
-(void)didBeginContact:(SKPhysicsContact *)contact
{
	
	// Set variables for two physics bodies
	SKPhysicsBody *body1, *body2;
	
	// Determine which one is bodyA and bodyB based on the categoryBitMask numbers
	if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
		body1 = contact.bodyA;
		body2 = contact.bodyB;
	} else {
		body1 = contact.bodyB;
		body2 = contact.bodyA;
	}
	
	// Check whether the laser is colliding with the enemy or the asteroid.
	if ((body1.categoryBitMask & laserCategory) != 0 && (body2.categoryBitMask & enemyCategory) != 0) {
		// Laser hit an enemy (body1 is the laser & body2 is the enemy)
		[self laser:(SKSpriteNode*) body1.node hitEnemy:(SKSpriteNode *) body2.node];
		
	} else if ((body1.categoryBitMask & laserCategory) != 0 && (body2.categoryBitMask & asteroidCategory) != 0) {
		// Laser hit an asteroid (body1 is the laser & body2 is the asteroid)
		[self laser:(SKSpriteNode *) body1.node hitAsteroid:(SKSpriteNode *) body2.node];
		
	} else if ((body1.categoryBitMask & enemyLaserCategory) != 0 && (body2.categoryBitMask & playerCategory) != 0) {
		// Enemy laser hit the player
		[self enemyLaser:(SKSpriteNode*)body1.node hitPlayer:(SKSpriteNode*)body2.node];
		
	} else if ((body1.categoryBitMask & enemyLaserCategory) != 0 && (body2.categoryBitMask & asteroidCategory) != 0) {
		// Enemy laser hit an asteroid
		[self enemyLaser:(SKSpriteNode*)body1.node hitAsteroid:(SKSpriteNode*)body2.node];
	}
	
}

// Called when enemy laser hits player
- (void)enemyLaser:(SKSpriteNode*)laser hitPlayer:(SKSpriteNode*)player
{
	
	// Play hit sound
	[self playSfx:@"hit"];
	
	// Create explosion animation
	[self createExplosion:laser];
	
	// Remove the laser
	[laser removeFromParent];
	
	// Lower player health by 1 point
	if (self.playerHealth > 0) {
		self.playerHealth -= 1;
		self.healthLabel.text = [NSString stringWithFormat:@"Health: %d", self.playerHealth];
	}
	
	// Update label
	if (self.playerHealth <= 3 && self.playerHealth > 1) {
		// If player health is at 2 or 3 make the label orange to warn them
		self.healthLabel.fontColor = [SKColor orangeColor];
	} else if (self.playerHealth == 1) {
		// If player health is 1 make the label red
		self.healthLabel.fontColor = [SKColor redColor];
	}
	
	if (self.playerHealth == 0) {
		// If the health is 0, the game ends in a loss
		// The player lost, so the playerData will not change. Just save the game.
		[self saveGame];
		SKTransition *gameOverTrans = [SKTransition flipVerticalWithDuration:0.5];
		SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size wonGame:NO filename:fileName];
		[self.view presentScene:gameOverScene transition:gameOverTrans];
	}
	
}

// Called when enemy laser hits asteroid
- (void)enemyLaser:(SKSpriteNode*)laser hitAsteroid:(SKSpriteNode*)asteroid
{
	
	// Play hit2 sound
	[self playSfx:@"hit2"];
	
	// Just create an explosion and remove the laser from the scene
	[self createExplosion:laser];
	[laser removeFromParent];
	
	// When an asteroid is hit, make it rotate
	SKAction *rotateAction = [SKAction rotateByAngle:M_PI duration:4.0];
	[asteroid runAction:rotateAction];
	
}



// Called when a laser hits an enemy
- (void)laser:(SKSpriteNode*)laser hitEnemy:(SKSpriteNode*)enemy
{
	
	// Play hit sound
	[self playSfx:@"hit"];
	
	// Remove the killed enemy from the enemiesArray
	[enemiesArray removeObject:enemy];
	
	// Create an explosion animation
	[self createExplosion:laser];
	
	// Remove the laser and the enemy
	[laser removeFromParent];
	[enemy removeFromParent];
	
	// Increase the score by 1 and update the Score Label accordingly
	self.score++;
	self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", self.score];
	
	// Provide visual feedback for when the player is within 3 kills of the required amount of kills by making the Score Label orange
	if (self.score > self.level.killsRequired - 4) {
		self.scoreLabel.fontColor = [SKColor orangeColor];
	}
	
	// If the player gets to X number of kills, they have won the round and we'll present the GameOverScene.
	if (self.score == self.level.killsRequired) {
		
		self.scoreLabel.fontColor = [SKColor greenColor];
		
		// Flag game over
		gameIsOver = YES;
		
		// Save the game
		[self handleWin];
		
	}
}

// Called when a laser hits an asteroid (no points are awarded)
- (void)laser:(SKSpriteNode*)laser hitAsteroid:(SKSpriteNode*)asteroid
{
	
	// Play hit2 sound
	[self playSfx:@"hit2"];
	
	// Just create an explosion and remove the laser from the scene
	[self createExplosion:laser];
	[laser removeFromParent];
	
	// When an asteroid is hit, make it rotate
	SKAction *rotateAction = [SKAction rotateByAngle:M_PI duration:4.0];
	[asteroid runAction:rotateAction];
}






#pragma End of Game Methods

// Called when the game ends (win or lose) to save the PlayerData singleton
- (void)saveGame
{
	
	[[PlayerData sharedPlayerData] save];
	
	
}

// Called when the game is over and the player won
- (void)handleWin
{
	
	[PlayerData sharedPlayerData].careerKills += self.score;
	
	// Update PlayerData singleton with new information
	// If the player has completed less than all 11 levels, they need to have a new level to play
	if ([PlayerData sharedPlayerData].levelsCompleted < 11) {
		
		// Call [self getLevel] to see if this level has been completed already. If NOT, this is the first time this level has been completed, so increase the levelsCompleted by 1 and set the rewards
		[PlayerData sharedPlayerData].availableShips = [self getAvailableShips];
		[PlayerData sharedPlayerData].availableLasers = [self getAvailableLasers];
		
		if ([self getLevel] == NO) {
			[PlayerData sharedPlayerData].levelsCompleted += 1;

		} else if (self.level.levelNumber == 0) {
			[PlayerData sharedPlayerData].levelsCompleted += 1;
		}
		NSLog(@"Win. LevelsCompleted: %d", [PlayerData sharedPlayerData].levelsCompleted);
	}
	
	if (self.level.levelNumber == 11) {
		if (self.playerHealth == 5) {
			[[GameKitHelper sharedInstance] updateAchievements:11 win:YES health:self.playerHealth score:[PlayerData sharedPlayerData].careerKills];
		}
	}
	
	saveData.careerScore += self.score;
	[saveData saveInBackground];

	
	[self saveGame];
	
	[[GameKitHelper sharedInstance] postScore:[PlayerData sharedPlayerData].careerKills];
	[[GameKitHelper sharedInstance] updateAchievements:self.level.levelNumber win:YES health:self.playerHealth score:[PlayerData sharedPlayerData].careerKills];
	
	// If there is nothing being rewarded after this level go straight to the Game Over scene
	if (!isAwardingPrize) {
		SKTransition *gameOverTrans = [SKTransition flipVerticalWithDuration:0.5];
		SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size wonGame:YES filename:fileName];
		[self.view presentScene:gameOverScene transition:gameOverTrans];
	}
	
}

// Checks to see if the current level has been flagged in [PlayerData] as completed
- (BOOL)getLevel
{
	
	// By default, each levelXComplete is set to NO, meaning they have not completed the level
	// When this method is called, the current level will have just been completed, so it will set the current levelXComplete to YES.
	
	// If the current level is X and [PlayerData sharedPlayerData].levelXComplete is NO, set it to YES and return NO to tell handleWin method that
	if (self.level.levelNumber == 1 && [PlayerData sharedPlayerData].level1Complete == NO) {
		[PlayerData sharedPlayerData].level1Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 2 && [PlayerData sharedPlayerData].level2Complete == NO) {
		[PlayerData sharedPlayerData].level2Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 3 && [PlayerData sharedPlayerData].level3Complete == NO) {
		[PlayerData sharedPlayerData].level3Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 4 && [PlayerData sharedPlayerData].level4Complete == NO) {
		[PlayerData sharedPlayerData].level4Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 5 && [PlayerData sharedPlayerData].level5Complete == NO) {
		[PlayerData sharedPlayerData].level5Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 6 && [PlayerData sharedPlayerData].level6Complete == NO) {
		[PlayerData sharedPlayerData].level6Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 7 && [PlayerData sharedPlayerData].level7Complete == NO) {
		[PlayerData sharedPlayerData].level7Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 8 && [PlayerData sharedPlayerData].level8Complete == NO) {
		[PlayerData sharedPlayerData].level8Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 9 && [PlayerData sharedPlayerData].level9Complete == NO) {
		[PlayerData sharedPlayerData].level9Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 10 && [PlayerData sharedPlayerData].level10Complete == NO) {
		[PlayerData sharedPlayerData].level10Complete = YES;
		return NO;
	} else if (self.level.levelNumber == 11 && [PlayerData sharedPlayerData].level11Complete == NO) {
		[PlayerData sharedPlayerData].level11Complete = YES;
		return NO;
	}
	
	return YES;
	
}

// Returns the amount of ships available based on the level that has just been completed
- (NSInteger)getAvailableShips
{
	
	int level;
	
	if (self.level.levelNumber < 5) {
		level = 1;
	} else if (self.level.levelNumber >= 5 && self.level.levelNumber < 8) {
		if (self.level.levelNumber == 5 && [PlayerData sharedPlayerData].level5Complete == NO) {
			// Award player green ship at Level 5
			[self prizeWithLabel:@"GREEN SHIP!" withSprite:@"greenShip"];
		}
		level = 2;
	} else if (self.level.levelNumber >= 8 && self.level.levelNumber <= 11) {
		if (self.level.levelNumber == 8 && [PlayerData sharedPlayerData].level8Complete == NO) {
			// Award player red ship at Level 8
			[self prizeWithLabel:@"RED SHIP!" withSprite:@"redShip"];
		}
		level = 3;
	}
	return level;
	
}

// Returns the amount of lasers available based on the level that has just been completed
- (NSInteger)getAvailableLasers
{
	
	int level;
	
	if (self.level.levelNumber < 3) {
		level = 1;
	} else if (self.level.levelNumber >= 3 && self.level.levelNumber < 7) {
		if (self.level.levelNumber == 3 && [PlayerData sharedPlayerData].level3Complete == NO) {
			// Award player green laser at Level 3
			[self prizeWithLabel:@"GREEN LASER!" withSprite:@"greenLaser"];
		}
		level = 2;
	} else if (self.level.levelNumber >= 7 && self.level.levelNumber <= 11) {
		if (self.level.levelNumber == 7 && [PlayerData sharedPlayerData].level7Complete == NO) {
			// Award player red laser at Level 7
			[self prizeWithLabel:@"RED LASER!" withSprite:@"redLaser"];
		}
		level = 3;
	}
	return level;
	
}




#pragma Player Awards Method

// Creates a popover screen that tells the player that they just unlocked a new ship or laser
- (void)prizeWithLabel:(NSString*)prizeLabelText withSprite:(NSString*)spriteName
{
	
	[self playSfx:@"reward"];
	
	//[self removeAllActions];
	// Set isAwardingPrize flag to YES
	//*** Remember to set it to NO when it's dismissed
	isAwardingPrize = YES;
	
	// Semi-clear background for this message
	prizeBackground = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:CGSizeMake(self.frame.size.width, self.frame.size.height)];
	prizeBackground.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
	prizeBackground.alpha = 0.8;
	prizeBackground.name = @"awardBackground";
	[self addChild:prizeBackground];
	
	// Congratulating Title Label
	title = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	title.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height - [self convertValue:50]);
	title.fontColor = [SKColor whiteColor];
	title.fontSize = [self convertValue:24];
	title.name = @"title";
	title.text = @"Congratulations! You have unlocked the...";
	[self addChild:title];
	
	// Show the award
	prizeSprite = [SKSpriteNode spriteNodeWithTexture:[_spriteTextureAtlas textureNamed:spriteName]];
	prizeSprite.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 );
	prizeSprite.anchorPoint = CGPointMake(0.5, 0);
	prizeSprite.name = @"greenLaser";
	[prizeSprite setScale:2.0];
	[self addChild:prizeSprite];
	
	// Show the name of the award
	label = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	label.position = CGPointMake(self.frame.size.width / 2, prizeSprite.position.y - [self convertValue:50]);
	label.fontSize = [self convertValue:28];
	label.fontColor = [SKColor whiteColor];
	label.name = @"label";
	label.text = prizeLabelText;
	[self addChild:label];
	
	// OK button node to dismiss this message
	ok = [[SKLabelNode alloc] initWithFontNamed:@"Futura-CondensedMedium"];
	ok.position = CGPointMake(self.frame.size.width / 2, [self convertValue: 75]);
	ok.fontColor = [SKColor yellowColor];
	ok.fontSize = [self convertValue:24];
	ok.name = @"ok";
	ok.text = @"OK";
	[self addChild:ok];
	
}


@end
