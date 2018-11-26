//
//  JMapPathPerFloor.h
//  JMap
//
//  Created by Bryan Hayes on 2015-08-31.
//  Copyright (c) 2015 jibestream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMapASEdge;
@class JMapPathType;
@class JMapPoint;

/**
 *  The JMapPathPerFloor model.
 */
@interface JMapPathPerFloor : NSObject

/**
 *  The map ID associated to the path per floor object.
 */
@property NSNumber *mapId;
/**
 *  The mover/path type associated to the path per floor object.
 */
@property JMapPathType *mover;
/**
 *  A list of JMapASNode objects associated to the path per floor object.
 */
@property NSMutableArray <JMapASNode*> *points;
/**
 *  A list of JMapPoint objects associated to the path per floor object.
 */
@property NSMutableArray <JMapPoint*> *mapPoints;
/**
 *  The cost of the path per floor object.
 */
@property float cost;

@end
