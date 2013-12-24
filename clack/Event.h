//
//  Event.h
//  clack
//
//  Created by Evan Brooks on 12/17/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * snippet;

@end
