//
//  ImageAttachment.m
//  clack
//
//  Created by Evan Brooks on 12/17/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//

#import "ImageAttachment.h"

@implementation ImageAttachment

- (id)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    //FLOG(@"initWithData called");
    //FLOG(@"uti is %@", uti);
    self = [super initWithData:contentData ofType:uti];
    
    if (self) {
        if (self.image == nil) {
            //FLOG(@" self.image is nil");
            self.image = [UIImage imageWithData:contentData];
        } else {
            //FLOG(@" self.image is NOT nil");
        }
    }
    return self;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    
    //FLOG(@"attachmentBoundsForTextContainer:proposedLineFragment:glyphPosition:characterIndex: called");
    float width = lineFrag.size.width;
    
    return [self scaleImageSizeToWidth:width];
}

// Scale the image to fit the line width
- (CGRect)scaleImageSizeToWidth:(float)width {
    
    float scalingFactor = 1.0;
    
    CGSize imageSize = [self.image size];
    
    //if (width < imageSize.width) {
        //scalingFactor = (width*0.9) / imageSize.width;
        scalingFactor = width / imageSize.width;
    //}
    
    CGRect rect = CGRectMake(0, 0, imageSize.width * scalingFactor, imageSize.height * scalingFactor);
    
    return rect;
    
}
@end