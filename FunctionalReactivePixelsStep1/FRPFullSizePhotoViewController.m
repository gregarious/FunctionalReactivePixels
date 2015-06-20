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
@property (nonatomic) NSInteger photoIndex;     // needed to carry state from setPhotoModels:currentPhotoIndex: to viewDidLoad
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
    self.title = [photoModelArray[photoIndex] photoName];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"embedPages"]) {
        self.pageViewController = segue.destinationViewController;
    }
}

#pragma mark - Private
#pragma mark <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    FRPPhotoViewController *currentVC = pageViewController.viewControllers.firstObject;
    self.title = currentVC.photoModel.photoName;
    [self.delegate userDidScroll:self toPhotoAtIndex:currentVC.photoIndex];
}

#pragma mark <UIPageViewControllerDataSource>

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

#pragma mark Helpers

- (UIViewController *)buildPhotoViewControllerForIndex:(NSInteger)photoIndex
{
    if (photoIndex >= 0 && photoIndex < self.photoModelArray.count) {
        FRPPhotoModel *photo = self.photoModelArray[photoIndex];
        FRPPhotoViewController *photoViewController = [[FRPPhotoViewController alloc] initWithNibName:@"FRPPhotoViewController" bundle:[NSBundle mainBundle]];
        [photoViewController setPhotoModel:photo photoIndex:photoIndex];
        return photoViewController;
    }
    return nil;
}

@end
