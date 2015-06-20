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
@property (nonatomic, strong) FRPPhotoModel *photoModel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation FRPPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    RAC(self.imageView, image) = [RACObserve(self.photoModel, fullsizedData) map:^id(id value) {
        return [UIImage imageWithData:value];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.imageView.image == nil) {
        [SVProgressHUD show];
        [[FRPPhotoImporter fetchPhotoDetails:self.photoModel] subscribeError:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        } completed:^{
            [SVProgressHUD dismiss];
        }];

    }}

- (void)setPhotoModel:(FRPPhotoModel *)photoModel photoIndex:(NSInteger)index
{
    self.photoModel = photoModel;
    self.photoIndex = index;
}

@end
