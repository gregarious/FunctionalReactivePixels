//
//  FRPFullSizePhotoViewController.h
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FRPFullSizePhotoViewControllerDelegate;

@interface FRPFullSizePhotoViewController : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

- (void)setPhotoModels:(NSArray *)photoModelArray currentPhotoIndex:(NSInteger)photoIndex;

@property (nonatomic, weak) id<FRPFullSizePhotoViewControllerDelegate> delegate;

@end

@protocol FRPFullSizePhotoViewControllerDelegate <NSObject>

- (void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index;

@end