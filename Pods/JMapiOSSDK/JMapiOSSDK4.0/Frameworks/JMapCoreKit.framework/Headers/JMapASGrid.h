//
//  JMapASGrid.h
//  JMap
//
//  Created by Bryan Hayes on 2015-09-01.
//  Copyright (c) 2015 jibestream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JMapWaypoint;
@class JMapPathPerFloor;
@class JMapASNode;
@class JMapASEdge;
@class JMapPath;
@class JMapNeighbor;

/**
 *  The JMapASGrid model.
 */
@interface JMapASGrid : NSObject
/**
 *  The vertical scale of the grid. Default to 100 of type float.
 */
@property NSNumber *verticalScale;
/**
 *  The list of JMapWaypoint objects on the grid.
 */
@property NSArray *waypoints;
/**
 *  The list of JMapPath objects on the grid.
 */
@property NSArray *paths;
/**
 *  The list of JMapPathType objects on the grid.
 */
@property NSArray *pathTypes;
/**
 *  The list of JMapMap objects on the grid.
 */
@property NSArray *mapFulls;
/**
 *  The list of JMapASNode objects on the grid.
 */
@property NSMutableArray *nodes;
/**
 *  The list of JMapASEdge objects on the grid.
 */
@property NSMutableArray *edges;
/**
 *  The list of JMapBuilding objects on the grid.
 */
@property NSArray *buildings;
/**
 *  The list of JMapFloor objects on the grid.
 */
@property NSMutableArray *floors;
/**
 *  Initializes a JMapASGrid.
 *
 *  @param waypointsIn The list of JMapWaypoint objects.
 *  @param pathsIn The list of JMapPath objects.
 *  @param pathTypesIn The list of JMapPathType objects.
 *  @param mapFullsIn The list of JMapMap objects.
 *  @param buildings The list of JMapBuilding objects.
 *  @return An initialized JMapASGrid instance.
 */
-(id)initASGrid:(NSArray *)waypointsIn pathsIn:(NSArray *)pathsIn pathTypesIn:(NSArray *)pathTypesIn mapFullsIn:(NSArray *)mapFullsIn buildings:(NSArray *)buildings;
/**
 *  Gets the Z value of the map with the map ID.
 *
 *  @param mapId The map ID.
 *  @return The map's Z value of type float.
 */
-(float) getMapZValue:(int)mapId;
/**
 *  Gets the path type with the path type ID.
 *
 *  @param pathTypeId The path type ID.
 *  @return A JMapPathType object associated to the path type ID.
 */
-(JMapPathType *)getPathTypeById:(int)pathTypeId;
/**
 *  Resets the grid and sets all JMapASNode objects to their default values.
 */
-(void)reset;
/**
 *  Gets the node with the node ID.
 *
 *  @param idIn The node ID.
 *  @return A JMapASNode object associated to the node ID.
 */
-(JMapASNode *) getNodeById:(int)idIn;
/**
 *  Gets the neighbor node with the node ID.
 *
 *  @param idIn The node ID.
 *  @return A JMapASNode object neighbor node associated to the node ID.
 */
-(JMapASNode *) getNeighborNodeObject:(int)idIn;

@end
