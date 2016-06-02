//
//  FirstViewController.m
//  KSTO
//
//  Created by Drew Volz on 6/7/14.
//  Copyright (c) 2014 Drew Volz. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "FirstViewController.h"
#import "MarqueeLabel.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <QuartzCore/QuartzCore.h>
#import "SnowFallView.h"

@interface FirstViewController ()
@property (strong, nonatomic) MPMoviePlayerController *streamPlayer;
@end

@implementation FirstViewController
@synthesize streamPlayer = _streamPlayer;
@synthesize nowPlayingText;
@synthesize nowPlayingToolbar;
@synthesize metadataInfo;
@synthesize slider;
@synthesize narwhalImage;

NSInteger num = 1;
NSInteger snowBool = 1;
UIImageView *imageview;
UIImageView *imageview2;
UIButton *callButton;
NSArray *splitInfo;
SnowFallView *sfv;
BOOL inBackground;

- (void)viewDidLoad {

        // Give it a title for the bottom icon
        self.title = @"KSTO Radio";
    
        // Constants
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
        // Navigation bar
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, 64.0)];
        // Title of controller
        UINavigationItem *callItem = [[UINavigationItem alloc]initWithTitle:@"KSTO Radio | 93.1 FM"];
        // Call button
        UIBarButtonItem *callButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"call.png"] style:UIBarButtonItemStylePlain target:self action:@selector(callTheStation:)];
    
        // Only set nav bar if we are able to place calls
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel:5077863602"]]) {
            [callItem setLeftBarButtonItem:callButton];
            navBar.items = @[callItem];
        }

        [navBar setBarTintColor:[UIColor whiteColor]];
        [self.view addSubview:navBar];
    
    
    
        // Show the background image
        _backgroundImage = [[UIImageView alloc] init];
        UIImage *bgImage = [UIImage imageNamed:@"bg.png"];
        _backgroundImage.image = bgImage;
        _backgroundImage.frame = CGRectMake(0, 0, width, height);
        [self.view addSubview: _backgroundImage];
        [self.view sendSubviewToBack: _backgroundImage];

    
        // Show record image
        imageview2 = [[UIImageView alloc] init];
        UIImage *recordImage = [UIImage imageNamed:@"record.png"];
        imageview2.image = recordImage;
    
        // Get a single tap to change speed of record
        [imageview2 setUserInteractionEnabled:YES];
        UITapGestureRecognizer *scratchRecord = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scratchTheRecord:)];
        [scratchRecord setNumberOfTapsRequired:1];
        [imageview2 addGestureRecognizer:scratchRecord];

    
        // Show the record with logo image
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if ([UIScreen mainScreen].bounds.size.height > 568.0) {
                //move to your iphone6 and beyond
                imageview2.frame = CGRectMake(15, 130, 350, 350);
            }
            else if ([UIScreen mainScreen].bounds.size.height == 568.0) {
                //move to your iphone5
                imageview2.frame = CGRectMake(10, 130, 300, 300);
            }
            else{
                //move to your iphone4s and below
                imageview2.frame = CGRectMake(35, 110, 250, 250);
            }
        }
        [self.view addSubview:imageview2];
    
    
    
    // Show the volume slider
    CGRect frame;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if ([UIScreen mainScreen].bounds.size.height > 568.0) {
                //move to your iphone6 and beyond
                frame = CGRectMake(145.0, 510.0, 200.0, 50.0);
            }
            else if([UIScreen mainScreen].bounds.size.height == 568.0){
                //move to your iphone5
                frame = CGRectMake(105.0, 450.0, 200.0, 50.0);
            }
            else{
                //move to your iphone4s and below
                frame = CGRectMake(105.0, 360.0, 200.0, 50.0);
            }
        }
    
        slider = [[UISlider alloc] initWithFrame:frame];
        [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        [slider setBackgroundColor:[UIColor clearColor]];
        slider.minimumValue = 0.0;
        slider.maximumValue = 1.0;
        slider.continuous = YES;
        slider.value = [[MPMusicPlayerController applicationMusicPlayer] volume];
        [self.view addSubview:slider];
        [self.view bringSubviewToFront:slider];

    
        // Show play button
        imageview = [[UIImageView alloc] init];
        UIImage *playButton = [UIImage imageNamed:@"play.png"];
        imageview.image = playButton;
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone){
            if ([UIScreen mainScreen].bounds.size.height > 568.0) {
                //move to your iphone6 and beyond
                imageview.frame = CGRectMake(30, 494, 75, 75);
            }
            else if([UIScreen mainScreen].bounds.size.height == 568.0){
                //move to your iphone5
                imageview.frame = CGRectMake(20, 440, 60, 60);
            }
            else{
                //move to your iphone4s and below
                imageview.frame = CGRectMake(20, 350, 60, 60);
            }
        }
        [self.view addSubview:imageview];
    
        // Get a tap and hold to scratch the record
        [imageview setUserInteractionEnabled:YES];
        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapping:)];
        [singleTap setNumberOfTapsRequired:1];
        [imageview addGestureRecognizer:singleTap];
    
    
        // Now Playing text
        nowPlayingText = [[MarqueeLabel alloc] initWithFrame:CGRectMake(0.0 , 0.0f, self.view.frame.size.width - 31.0f, 21.0f) duration:8.0 andFadeLength:10.0f];
    
        nowPlayingText.marqueeType = MLContinuous;
        nowPlayingText.continuousMarqueeExtraBuffer = 50.0f;
        [nowPlayingText setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [nowPlayingText setBackgroundColor:[UIColor clearColor]];
        UIColor *ios7BlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        [nowPlayingText setTextColor: ios7BlueColor];
    
        // This is where the now playing text is set!
        [nowPlayingText setText: @""];

        UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:nowPlayingText];
        nowPlayingToolbar.items = @[title];
    


        // Where the music is coming from
        NSURL *streamURL = [NSURL URLWithString:@"http://stolaf-flash.streamguys.net/radio/ksto1.stream/playlist.m3u8"];
        _streamPlayer = [[MPMoviePlayerController alloc] initWithContentURL:streamURL];
    
        
        // depending on your implementation your view may not have it's bounds set here
        [self.streamPlayer.view setFrame:CGRectMake(0, 485 ,height=0, width=0)];
        self.streamPlayer.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview: self.streamPlayer.view];

        [UIApplication sharedApplication].idleTimerDisabled = YES;
    
        self.nowPlayingToolbar.clipsToBounds = YES;
    
    
        // Observers using local notifications for app activities
    
        // Our observer for seeing if the app became active. I use this to make the animation
        // work smoothly, as in stop it and restart it.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationEnteredForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        // Our observer for seeing if the app went away. I use this to make the animation
        // stop and restart.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationEnteredBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        // Our observer for seeing if the app will quit. I use this to make the animation
        // stop completely and to reset the count on play/pause.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillTerminate:)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];

        // Our observer for updating the song info metadata. I use this to make the information
        // about what is playing accurate (and exist).
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MetadataUpdate:)
                                                 name:MPMoviePlayerTimedMetadataUpdatedNotification
                                               object:nil];
    
        // Our observer to see if the volume is changed.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:)
                                                 name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    
        // Our observer for check if our audio was interrupted. I use this to handle the
        // case where we are...well...interrupted by other audio/app
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(interruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:[AVAudioSession sharedInstance]];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(routeChange:)
                                                     name:AVAudioSessionRouteChangeNotification
                                                   object:nil];
    
    
    // number is odd [PLAY]
    if (num % 2) {
        [self stopTheRecord];
        [self rotateTheRecord];
    }
}


// Play music action
- (void)singleTapping:(UIGestureRecognizer *)recognizer {
    
    // number is odd [PLAY]
    if (num % 2) {
        // check if we have internet
        if([self hasConnectivity] == YES) {
            // play the stream
            [self.streamPlayer play];
            imageview.image = [UIImage imageNamed:@"pause.png"];
            // Increment a number, and change it from pause to play every time we touch the image
            num++;
            
            // Rotate the record
            [self rotateTheRecord];
            // Show the "Now Playing" text
            [self fadeIn];
        }
        
        else if([self hasConnectivity] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Available" message:@"Please connect to a network." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            // optional - add more buttons:
            [alert show];
            // Hide the "Now Playing" text
            [self fadeOut];
        }
    }
    // number is even [PAUSE]
    else {
        // pause the stream
        [self.streamPlayer pause];
        imageview.image = [UIImage imageNamed:@"play.png"];
        num++;
        
        // Stop the record spinning
        [self stopTheRecord];
        
        // Remove the falling narwhals
        [sfv removeFromSuperview];
        snowBool = 1;
    }
}


// Make narwhal images fall from top to bottom of screen on record touch
- (void)scratchTheRecord:(UIGestureRecognizer *)recognizer {
    
    // if we are not falling snow and we are playing music...
    if(snowBool == 1 && !(num % 2)) {
        // produce many falling narwhals
        sfv = [[SnowFallView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width * 2, self.view.frame.size.height * 2)];
        [self.view addSubview:sfv];
        [sfv letItSnow];
        
        [self.view bringSubviewToFront:imageview];
        [self.view bringSubviewToFront:imageview2];
        [self.view bringSubviewToFront:slider];
        
        snowBool = 0;
    }
    else {
        [sfv removeFromSuperview];
        snowBool = 1;
    }
}


- (void)viewDidAppear:(BOOL)animated {
    inBackground = false;
    
    // Turn on remote control event delivery
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // Set itself as the first responder
    [self becomeFirstResponder];
    
    //Check if we are currently playing something
    if(_streamPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        // Restart the record spinning
        [imageview2 stopAnimating];
        [self stopTheRecord];
        [self removeAnimations];
        [self rotateTheRecord];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Resign as the first responder
    [self resignFirstResponder];
    
    // Remove the falling narwhals
    [sfv removeFromSuperview];
    snowBool = 1;
}


- (void)applicationEnteredForeground:(NSNotification *)notification {
    inBackground = false;
    //Check if we are currently playing something
    if(_streamPlayer.playbackState == MPMoviePlaybackStatePlaying) {
        // Restart the record spinning
        [self rotateTheRecord];
    }
}

- (void)applicationEnteredBackground:(NSNotification *)notification {
    inBackground = true;
    [imageview2 stopAnimating];
    [self stopTheRecord];
    [self removeAnimations];
    
    // Remove the falling narwhals
    [sfv removeFromSuperview];
    snowBool = 1;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    num = 1;
    [self stopTheRecord];
    [self removeAnimations];
}

// Get song artist and track only if we receive a notification and we are playing music
- (void)MetadataUpdate:(NSNotification*)notification
{
    if (([_streamPlayer timedMetadata]!=nil) && ([[_streamPlayer timedMetadata] count] > 0)) {
        // Pull out the newly received song and artist info
        MPTimedMetadata *firstMeta = [[_streamPlayer timedMetadata] objectAtIndex:0];
        
        // Fade out, then in the "Now Playing" text in the block
        [self fadeOutThenIn];
        
        // Pass the new song info to a global variable
        metadataInfo = firstMeta.value;

        // Push the changes to the lockscreen/control center
        [self updateLockScreenInfo];
    }
}


// Rotate animation method
- (void)rotateTheRecord {

    // Set how fast we rotate
    float speed = 0.6;
    
    // Rotates 180 degrees (M_PI_2) over and over in a circle
    [UIView animateWithDuration:speed delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
        [imageview2 setTransform:CGAffineTransformRotate(imageview2.transform, M_PI_2)];
    }completion:^(BOOL finished){
        // repeat the 180 degree rotation once we rotate 180 degrees...
        // ...and check that we have not pushed pause
        if (finished && !(num % 2)) {
            [self removeAnimations];
            [self rotateTheRecord];
        }
    }];
}

// Stop rotating animation method
- (void)stopTheRecord {

    // Stop rotating
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0];
    [UIView setAnimationRepeatCount:0];
    [UIView commitAnimations];
}

// Remove animations
- (void)removeAnimations {
    // Remove all animations that are present
    [imageview2.layer removeAllAnimations];
}


// Fade the "now playing" label in nicely
-(void) fadeIn {
    // Set the alpha so we are at none
    nowPlayingText.alpha = 0;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    //don't forget to add delegate.....
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDuration:1];
    
    // Set the alpha so we are at full
    nowPlayingText.alpha = 1;
    
    [UIView commitAnimations];
}

// Fade the "now playing" label in nicely
-(void) fadeOut {
    // Set the alpha so we are at full
    nowPlayingText.alpha = 1;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    //don't forget to add delegate
    [UIView setAnimationDelegate:self];
    
    [UIView setAnimationDuration:1];
    
    // Set the alpha so we are at none
    nowPlayingText.alpha = 0;
    
    [UIView commitAnimations];
}

// Fade the "now playing" label out and then in nicely
-(void) fadeOutThenIn {
    // Set the alpha so we are at full
    nowPlayingText.alpha = 1;
    
    [UIView animateWithDuration:1
          delay:0
        options: UIViewAnimationCurveEaseInOut
     animations:^{
         // Set the alpha so we are at  none
         nowPlayingText.alpha = 0;
     }
     completion:^(BOOL finished){
         // Update the song and artist info
         nowPlayingText.text = metadataInfo;
         // Fade the "Now Playing" text back in
         [self fadeIn];
     }];
}

-(void)updateLockScreenInfo {
    // Control remotely from lockscreen or control center
    Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
    
    // Get the relevant song name and artist for display on lockscreen/control center
    if (playingInfoCenter && metadataInfo != NULL) {
        NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
        
        if(metadataInfo != NULL) {
            [songInfo setObject:metadataInfo forKey:MPMediaItemPropertyTitle]; // song name
        }
    
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo]; // make it happen
    }
}



// Handle interruption in audio: pause
-(void)handleInterruptionStarted {
    [imageview2 stopAnimating];
    [self stopTheRecord];
    [self removeAnimations];
    [self.streamPlayer pause];
}


// Handle interruption in audio: play
-(void)handleInterruptionEnded {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Interruption ended" object:self];
    [imageview2 stopAnimating];
    [self stopTheRecord];
    [self removeAnimations];
    [self rotateTheRecord];
    [self.streamPlayer play];
    
}


// Alert for calling the station
- (void)callTheStation:(UIGestureRecognizer *)recognizer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call KSTO Station" message:@"Do you want to call the station?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

// Checking if "Yes" was selected to call the station after the alert has been presented
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://5077863602"]];
    }
}


// Handling changing the volume through the slider
-(void)sliderAction:(id)sender {
    [[MPMusicPlayerController applicationMusicPlayer] setVolume: slider.value];
 }

// Seeing if the volume is changed with a notification
- (void)volumeChanged:(NSNotification *)notification
{
    float volume =
    [[[notification userInfo]
      objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"]
     floatValue];
    
    // Do stuff with volume
    slider.value = volume;
}




// Handling audio interruption
- (void)interruption:(NSNotification*)notification {
    // get the user info dictionary
    NSDictionary *interuptionDict = notification.userInfo;
    // get the AVAudioSessionInterruptionTypeKey enum from the dictionary
    NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    // decide what to do based on interruption type here...
    switch (interuptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            NSLog(@"Audio Session Interruption case started.");
            // fork to handling method here...
            [self handleInterruptionStarted];
            break;
            
        case AVAudioSessionInterruptionTypeEnded:
            NSLog(@"Audio Session Interruption case ended.");
            // fork to handling method here...
            [self handleInterruptionEnded];
            break;
            
        default:
            NSLog(@"Audio Session Interruption Notification case default.");
            break;
    }
}


-(void)routeChange:(NSNotification*)notification {
    
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonUnknown");
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // a headset was added or removed
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonCategoryChange");
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonOverride");
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonWakeFromSleep");
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"routeChangeReason : AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory");
            break;
            
        default:
            break;
    }
}

/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
-(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}


// Handle the remote controls from conrol center/lockscreen
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if ( receivedEvent.type == UIEventTypeRemoteControl ) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlStop:
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if (_streamPlayer.playbackState == MPMoviePlaybackStatePlaying  && inBackground == false) {
                    [self.streamPlayer pause];
                    [self stopTheRecord];
                    imageview.image = [UIImage imageNamed:@"play.png"];
                    num++;
                    [[MPMusicPlayerController applicationMusicPlayer] pause];
                }
                else if (_streamPlayer.playbackState == MPMoviePlaybackStatePlaying && inBackground == true) {
                    [self.streamPlayer pause];
                    [self stopTheRecord];
                    imageview.image = [UIImage imageNamed:@"play.png"];
                    num++;
                    [[MPMusicPlayerController applicationMusicPlayer] pause];
                }
                else if (_streamPlayer.playbackState == MPMoviePlaybackStatePaused && inBackground == true) {
                    [self.streamPlayer play];
                    imageview.image = [UIImage imageNamed:@"pause.png"];
                    num++;
                    [[MPMusicPlayerController applicationMusicPlayer] play];
                }
                else {
                    [self.streamPlayer play];
                    [self rotateTheRecord];
                    imageview.image = [UIImage imageNamed:@"pause.png"];
                    num++;
                    [[MPMusicPlayerController applicationMusicPlayer] play];
                }
                break;
                
            case UIEventSubtypeRemoteControlBeginSeekingBackward:
            case UIEventSubtypeRemoteControlBeginSeekingForward:
            case UIEventSubtypeRemoteControlEndSeekingBackward:
            case UIEventSubtypeRemoteControlEndSeekingForward:
            case UIEventSubtypeRemoteControlPreviousTrack:
            case UIEventSubtypeRemoteControlNextTrack:
                break;
                
            default:
                break;
        }
    }
}



// Define rotation information as only portrait
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Still tell it that it shouldn't rotate
-(BOOL)shouldAutorotate
{
    return NO;
}

// Only portrait
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
