//
//  SSNLastSeenViewController.h
//  AssassinApp
//
//  Created by Quinn McNamara on 7/30/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface SSNLastSeenViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) PFGeoPoint *targetPoint;

@end
