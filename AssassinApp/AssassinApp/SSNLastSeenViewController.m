//
//  SSNLastSeenViewController.m
//  AssassinApp
//
//  Created by Quinn McNamara on 7/30/15.
//  Copyright (c) 2015 Quinn McNamara. All rights reserved.
//

#import "SSNLastSeenViewController.h"

@interface SSNLastSeenViewController ()

@end

@implementation SSNLastSeenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(self.targetPoint.latitude, self.targetPoint.longitude);
    MKPlacemark *targetPlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    [self.mapView addAnnotation:targetPlacemark];
    
    [self zoomToCoordinate:coordinate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)zoomToCoordinate:(CLLocationCoordinate2D) coordinate
{
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center = coordinate;
    [self.mapView setRegion:region animated:YES];
}

@end
