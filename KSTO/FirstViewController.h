//
//  FirstViewController.h
//  KSTO
//
//  Created by Drew Volz on 6/7/14.
//  Copyright (c) 2014 Drew Volz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

@interface FirstViewController : UIViewController<UIAlertViewDelegate>{
    
    UIView *subView;
    UIView *airPlay;
}
// Background
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
// Narwhal
@property (strong, nonatomic) IBOutlet UIImageView *narwhalImage;


// White sub-view
@property (weak, nonatomic) IBOutlet UIToolbar *nowPlayingToolbar;
// Buttons and text
@property (weak, nonatomic) IBOutlet UIBarButtonItem *callStation;
// Special label that scrolls forwards and backwards as needed
@property (strong, nonatomic) IBOutlet MarqueeLabel *nowPlayingText;
@property (strong, nonatomic) IBOutlet MarqueeLabel *nowPlayingText2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *callButton;
@property (weak, nonatomic) IBOutlet NSString *metadataInfo;

// Volume
@property (nonatomic, strong) UISlider *slider;


// Custom methods
- (void) rotateTheRecord;
- (void) stopTheRecord;
- (void) removeAnimations;

@end

