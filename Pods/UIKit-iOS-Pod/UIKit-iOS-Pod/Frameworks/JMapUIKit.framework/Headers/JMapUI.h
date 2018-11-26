//
//  JMapUI.h
//  JMapUIKit
//
//  Created by Louie Yuen on 2018-03-23.
//  Copyright © 2018 Jibestream. All rights reserved.
//

#import <JMapCoreKit/JMapCoreKit.h>
#import <JMapControllerKit/JMapControllerKit.h>
#import "ContainerView.h"
#import "Popup.h"

/**
 *  The JMapUIDelegate object
 */
@protocol JMapUIDelegate <NSObject>

/**
 *  Delegate method for subscribing to the action button callback
 */
- (void)actionButtonCallback:(nonnull Popup *)popup;

/**
 *  Delegate method for subscribing to the search table item selection callback
 */
- (void)onSelect:(id)item;

@end

/**
 *  The JMapUI object
 */
@interface JMapUI : NSObject

/**
 *  The delegate
 */
@property (nonatomic, weak) id <JMapUIDelegate> delegate;

/**
 *  Contructor to create a JMapUI with controller
 *
 *  @param controller JMapController being used in implementation
 *  @param viewController The active view controller for overlaying the UI components 
 *  @param options For defining properties
 *  @code
 *  NSDictionary *dict = @{
 *      @"allowConcurrentPopups: NSNumber with boolean, defaults to false
 *  }
 *  @return newly created JMapUI object
 */
- (nonnull instancetype)initWithController:(nonnull JMapController *)controller andViewController:(nonnull UIViewController*)viewController andOptions:(nullable NSDictionary *)options;

/**
 *  Render floor selector on the screen
 *
 *  @param options For defining properties
 *  @code
 *  NSDictionary *dict = @{
 *      @"inactiveStyle": JMapStyle,
 *      @"activeStyle": JMapStyle,
 *      @"inactiveFont": UIFont,
 *      @"activeFont": UIFont,
 *      @"inactiveFontColor": UIColor,
 *      @"activeFontColor": UIColor,
 *      @"position": NSArray<NSNumber *> - [0~1, 0~1],
 *      @"vertical": NSNumber with boolean, defaults to true
 *      @"maxHeight": NSNumber
 *  }
 */
- (void)renderFloorSelectorWithOptions:(nullable NSDictionary *)options;

/**
 *  Render popup on the map
 *
 *  @param options For defining properties
 *  @code
 *  NSDictionary *dict = @{
 *      @"map": JMapMap,
 *      @"coordinates": NSValue,
 *      @"titleText": NSString,
 *      @"titleFont": UIFont,
 *      @"titleFontColor": UIColor,
 *      @"subText": NSString,
 *      @"subFont": UIFont,
 *      @"subFontColor": UIColor,
 *      @"showActionButton": NSNumber with boolean, defaults to false
 *      @"actionButtonText": NSString,
 *      @"actionButtonFont": UIFont,
 *      @"actionButtonStyle": JMapStyle,
 *      @"actionButtonFontColor": UIColor,
 *      @"popupStyle": JMapStyle
 *  }
 *
 *  @return The Popup instance created
 */
- (nonnull Popup *)renderPopupWithOptions:(nullable NSDictionary *)options;

/**
 *  Render search bar
 *
 *  @param options For defining properties
 *  @code
 *  NSDictionary *dict = @{
 *      @"position": NSNumber - 0~1,
 *      @"placeholder": NSString,
 *      @"searchArray": NSArray - JMapDestination, JMapAmenity, JMapPathType objects,
 *      @"maxResults": NSNumber,
 *      @"tableHeight": NSNumber
 *  }
 */
- (void)renderSearchWithOptions:(nullable NSDictionary *)options;

/**
 *  Render compass
 *
 *  @param options For defining properties
 *  @code
 *  NSDictionary *dict = @{
 *      @"position": NSArray<NSNumber *> - [0~1, 0~1],
 *      @"width": NSNumber with int, defaults to 50,
 *      @"height": NSNumber with int, defaults to 50,
 *      @"icon": UIView,
 *      @"rotatedIcon": UIView,
 *      @"resetRotationOnTap": NSNumber with boolean, defaults to true
 *  }
 */
- (void)renderCompassWithOptions:(nullable NSDictionary *)options;

/**
 *  Update compass angle
 *
 *  @param degrees the angle received from canvas:scrollViewDidRotateByDegrees:
 */
- (void)updateCompass:(float)degrees;

/**
 *  Getter for container view
 *
 *  @return ContainerView instance
 */
- (nonnull ContainerView *)getUIContainer;

@end
