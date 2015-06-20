//
//  FRPFullSizePhotoViewController.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import "FRPFullSizePhotoViewController.h"
#import "FRPPhotoViewController.h"
#import "FRPPhotoModel.h"

@interface FRPFullSizePhotoViewController ()
@property (nonatomic, weak) UIPageViewController *pageViewController;
@property (nonatomic, copy) NSArray *photoModelArray;
@property (nonatomic) NSInteger photoIndex;
@end

@implementation FRPFullSizePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    UIViewController *initialVC = [self buildPhotoViewControllerForIndex:self.photoIndex];
    [self.pageViewController setViewControllers:@[initialVC]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
}

- (void)setPhotoModels:(NSArray *)photoModelArray currentPhotoIndex:(NSInteger)photoIndex
{
    self.photoModelArray = photoModelArray;
    self.photoIndex = photoIndex;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedPages"]) {
        self.pageViewController = segue.destinationViewController;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    FRPPhotoViewController *vc = (FRPPhotoViewController *)viewController;
    return [self buildPhotoViewControllerForIndex:vc.photoIndex-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    FRPPhotoViewController *vc = (FRPPhotoViewController *)viewController;
    return [self buildPhotoViewControllerForIndex:vc.photoIndex+1];
}

- (UIViewController *)buildPhotoViewControllerForIndex:(NSInteger)photoIndex
{
    if (photoIndex >= 0 && photoIndex < self.photoModelArray.count) {
        FRPPhotoModel *photo = self.photoModelArray[photoIndex];
        FRPPhotoViewController *photoViewController = [[FRPPhotoViewController alloc] initWithNibName:@"FRPPhotoViewController" bundle:[NSBundle mainBundle]];
        [photoViewController setPhotoModel:photo photoIndex:photoIndex];
        photoViewController.title = photo.photoName;
        return photoViewController;
    }
    return nil;
}

@end
