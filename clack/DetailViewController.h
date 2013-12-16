//
//  DetailViewController.h
//  clack
//
//  Created by Evan Brooks on 12/16/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
