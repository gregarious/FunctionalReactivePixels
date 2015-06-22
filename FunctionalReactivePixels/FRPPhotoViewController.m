//
//  FRPPhotoViewController.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import "FRPPhotoViewController.h"
#import "FRPPhotoModel.h"
#import "FRPPhotoImporter.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface FRPPhotoViewController ()
@property (nonatomic, readwrite) NSInteger photoIndex;
@property (nonatomic, readwrite) FRPPhotoModel *photoModel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation FRPPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // bind our imageView to be reactive to view model's data changes
    RAC(self.imageView, image) = [[RACObserve(self.photoModel, fullsizedData) map:^id(id value) {
        return [UIImage imageWithData:value];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.imageView.image == nil) {
        [SVProgressHUD show];
        
        // big win here. no nested callbacks. just simply initiate soemthing that will mutate our viewmodel. this lets us hide the inner fetch since we know the above binding will update when appropriate
        // we still do need to keep track of our loading indicator though, but it's much more clear to see the flow here
        
        [[FRPPhotoImporter fetchPhotoDetails:self.photoModel] subscribeError:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"Error"];
            });
        } completed:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];

    }}

- (void)setPhotoModel:(FRPPhotoModel *)photoModel photoIndex:(NSInteger)index
{
    self.photoModel = photoModel;
    self.photoIndex = index;
}

@end
