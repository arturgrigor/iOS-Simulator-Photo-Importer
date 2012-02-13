//
//  AGAppDelegate.h
//  Photo Importer
//
//  Created by Artur Grigor on 2/13/12.
//  Copyright (c) 2012 Universitatea "Babes-Bolyai". All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGViewController;

@interface AGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AGViewController *viewController;

@end
