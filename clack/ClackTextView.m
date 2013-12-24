//
//  ClackTextView.m
//  clack
//
//  Created by Evan Brooks on 12/18/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//
//  Distinct class in order to pass touches up to the detail view controller.
//  Based on http://stackoverflow.com/questions/616411/iphone-how-to-handle-touches-on-a-uitextview
//
//

#import "ClackTextView.h"
#import "ImageAttachment.h"

@implementation ClackTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}

//- (void)setContentSize:(CGSize)contentSize {
//    NSLog(@"CS: %@", NSStringFromCGSize(contentSize));
//    [super setContentSize:contentSize];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //[self.nextResponder touchesBegan: touches withEvent:event];
    //[super              touchesBegan: touches withEvent:event];
    NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
    // Sending messages to the next responder is 'explicitly forbidden' by apple but at least it fucking works
    [[self.nextResponder nextResponder] touchesMoved: touches withEvent:event];
    [super              touchesMoved: touches withEvent:event];
    //NSLog(@"touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self.nextResponder nextResponder] touchesEnded: touches withEvent:event];
    [super              touchesEnded:touches withEvent:event];
    NSLog(@"****touchesEnded");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //[super touchesCancelled:touches withEvent:event];
    NSLog(@"touchesCancelled");
}
*/





@end
