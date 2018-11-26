//
//  JMapActiveVenue.h
//  JMapCore
//
//  Created by Louie Yuen on 2016-10-17.
//  Copyright © 2016 Jibestream. All rights reserved.
//

#import <JMapCoreKit/JMapCoreKit.h>

@class JMapWaypoint;
@class JMapMap;
@class JMapBuildingCollection;
@class JMapDestinationCollection;
@class JMapAmenityCollection;
@class JMapMapCollection;
@class JMapPathTypeCollection;
@class JMapMapLabelCollection;
@class JMapPathPerFloor;
@class JMapPosition;

/**
 *  The JMapActiveVenue model.
 */
@interface JMapActiveVenue : JMapBaseModel
/**
 *  The name of the active venue.
 */
@property (nonatomic, strong, readonly, nullable) NSString *name;
/**
 *  The map associated with the active venue
 */
@property (nonatomic, strong, readonly, nullable) JMapMap * map;
/**
 *  The venue status
 */
@property (nonatomic, assign, readonly) BOOL status;
/**
 *  The JMapPosition object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapPosition *coordinates;
/**
 *  The JMapBuildingCollection object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapBuildingCollection * buildings;
/**
 *  The JMapDestinationCollection object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapDestinationCollection * destinations;
/**
 *  The JMapAmenityCollection object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapAmenityCollection * amenities;
/**
 *  The JMapMapCollection object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapMapCollection * maps;
/**
 *  The JMapPathTypeCollection object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapPathTypeCollection * pathTypes;
/**
 *  The JMapMapLabelCollection object associated with the active venue.
 */
@property (nonatomic, strong, readonly, nullable) JMapMapLabelCollection * mapLabels;
/**
 *  Initializes a JMapActiveVenue.
 *
 *  @param dict An NSDictionary parsed from the server.
 *  @return An initialized JMapActiveVenue instance.
 */
-(nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

#pragma mark - Wayfind Helpers
/**
 *  Updates the wayfinding data to enable the wayfinding algorithm.
 *  @param completion The completion handler for when the data has been loaded successfully.
 */
- (void)updateWayfindDataWithCompletion:(nullable void(^)(BOOL success))completion;
/**
 *  Generates a list of wayfinding data with starting and ending waypoints with accessibility.
 *  @param waypointStart The starting waypoint to wayfind from.
 *  @param waypointEnd The ending waypoint to wayfind to.
 *  @param accessible The accessibility value of the wayfinding route. 0 - 100 with 100 having full accessibility.
 */
- (nonnull NSArray <JMapPathPerFloor *>*)wayfind:(nonnull JMapWaypoint *)waypointStart to:(nonnull JMapWaypoint *)waypointEnd  withAccessibility:(NSInteger)accessible;
/**
 *  Gets the nearest waypoint in an array from a reference waypoint.
 *  @param waypointArray An NSArray of JMapWaypoint objects to search in.
 *  @param waypoint The waypoint reference to search with.
 *  @param accessible The accessibility value of the wayfinding route used for calculating distance.
 */
- (nullable JMapWaypoint *)getClosestWaypointInArray:(nonnull NSArray <JMapWaypoint *>*)waypointArray toWaypoint:(nonnull JMapWaypoint *)waypoint withAccessibility:(NSInteger)accessible;
/**
 *  Gets the closest waypoint on the map from a given coordinate.
 *  @param map The JMapMap object to search in.
 *  @param coordinate The x,y coordinate reference to search with.
 */
- (nullable JMapWaypoint *)getClosestWaypointToCoordinateOnMap:(nonnull JMapMap *)map withCoordinate:(CGPoint)coordinate;
/**
 *  Gets the nearest waypoint in an array from a reference point.
 *  @param waypointArray An NSArray of JMapWaypoint objects to search in.
 *  @param point The point reference to search with.
 */
- (nullable JMapWaypoint *)getClosestWaypointInArray:(nonnull NSArray <JMapWaypoint *>*)waypointArray toCoordinate:(CGPoint)point;

@end
