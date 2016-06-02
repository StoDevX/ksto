//
//  AboutViewController.m
//  KSTO
//
//  Created by Drew Volz on 7/13/14.
//  Copyright (c) 2014 Drew Volz. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize aboutText;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Constants
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    // Navigation bar
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, width, 64.0)];
    // Title of controller
    UINavigationItem *titleItem = [[UINavigationItem alloc]initWithTitle:@"About"];
    
    navBar.items = @[titleItem];
    [navBar setBarTintColor:[UIColor whiteColor]];
    [self.view addSubview:navBar];
    
    
    // Show the background image
    _backgroundImage = [[UIImageView alloc] init];
    UIImage *bgImage = [UIImage imageNamed:@"bg.png"];
    _backgroundImage.image = bgImage;
    _backgroundImage.frame = CGRectMake(0, 0, width, height);
    [self.view addSubview: _backgroundImage];
    [self.view sendSubviewToBack: _backgroundImage];
    
    
    
    // Add text to the about section
    
    UITextView *myUITextView = [[UITextView alloc] initWithFrame:CGRectMake(5, 68, width - 40, height - 120)];
    myUITextView.text = @"KSTO is a student-run radio station of St. Olaf College in Northfield, Minnesota. The station broadcasts over the airwaves on campus at 93.1 FM, though most of our listeners access KSTO through the online stream, which is available by clicking “Listen Online” on our website, or through this iPhone application.\n\nKSTO has been on the air in one form or another without interruption (for the most part) since 1957.  In 1965, it installed its AM Carrier Current system which involved utilizing St. Olaf’s infamous steam tunnels to run wires from the station to each residence hall. At the time of its inception, KSTO served as an outlet for students to express their opinions, and its music format reflected the progressive views of the campus at the time.\n\nTo this day, KSTO offers the same opportunity to any St. Olaf student, asking only that on-air personalities adhere to the same FCC guidelines which govern every radio station in the country. Beyond that, there is no censorship or policies dictating what types of music students can play and what topics of conversation they can cover.\n\nAs St. Olaf continues to grow in numbers, KSTO continues to grow in popularity. Since 2000, KSTO has broadcast from a dedicated space on the lower level of Buntrock Commons, St. Olaf’s campus center. This production suite consists of a reception room, office for managers and music directors, on air studio, and recording studio.\n\n";
     
    myUITextView.textColor = [UIColor lightTextColor];
    myUITextView.font = [UIFont systemFontOfSize:15];
    myUITextView.editable = NO;
    myUITextView.scrollEnabled = YES;
    myUITextView.textAlignment = NSTextAlignmentJustified;
    myUITextView.showsHorizontalScrollIndicator = NO;
    myUITextView.showsVerticalScrollIndicator = NO;
    
    [myUITextView setBackgroundColor:[UIColor clearColor]];
    [myUITextView setScrollsToTop:YES];
    [aboutText addSubview:myUITextView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
