//
//  AboutViewController.h
//  KSTO
//
//  Created by Drew Volz on 7/13/14.
//  Copyright (c) 2014 Drew Volz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController

// Background
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UIScrollView *aboutText;
// Buttons and text
@property (weak, nonatomic) IBOutlet UIBarButtonItem *callStation;
// Special label that scrolls forwards and backwards as needed
@property (weak, nonatomic) IBOutlet UIBarButtonItem *callButton;
@end
