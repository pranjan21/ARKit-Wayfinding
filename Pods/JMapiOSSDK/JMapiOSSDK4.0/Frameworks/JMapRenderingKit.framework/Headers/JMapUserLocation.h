//
//  JMapUserLocation.h
//  JMapRendering
//
//  Created by Louie Yuen on 2016-11-08.
//  Copyright © 2016 Jibestream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JMapMovingObject.h"

/**
 *  The JMapUserLocation object.
 */
@interface JMapUserLocation : JMapMovingObject
/**
 *  Set whether the item view be centered on the view port
 */
@property (nonatomic, assign) BOOL tracking;

/**
 *  A singleton JMapUserLocation instance
 */
+ (instancetype)sharedInstance;

@end
