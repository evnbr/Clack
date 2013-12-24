//
//  FadeSegue.m
//  clack
//
//  Created by Evan Brooks on 12/17/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//

#import "FadeSegue.h"

@implementation FadeSegue

- (void) perform
{
    CATransition* transition = [CATransition animation];
    
    transition.duration = 0.15;
    transition.type = kCATransitionFade;
    
    [[self.sourceViewController navigationController].view.layer addAnimation:transition forKey:kCATransition];
    [[self.sourceViewController navigationController] pushViewController:[self destinationViewController] animated:NO];
}

@end
