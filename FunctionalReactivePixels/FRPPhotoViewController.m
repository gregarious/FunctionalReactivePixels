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

#import <SVProgressHUD/SVProgressHUD.h>

@interface FRPPhotoViewController ()
@property (nonatomic, readwrite) NSInteger photoIndex;
@property (nonatomic, readwrite) FRPPhotoModel *photoModel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation FRPPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.imageView.image == nil) {
        [SVProgressHUD show];
        
        __weak FRPPhotoViewController *weakSelf = self;
        // first pull the extended photo details
        [FRPPhotoImporter fetchPhotoDetails:self.photoModel completionBlock:^(FRPPhotoModel *photo, NSError *error) {
            if (photo) {
                // then the
                [FRPPhotoImporter downloadFullsizedImageForPhotoModel:photo completionBlock:^(NSData *data, NSError *error) {
                    if (data) {
                        [SVProgressHUD dismiss];
                        weakSelf.imageView.image = [UIImage imageWithData:data];
                    }
                    else {
                        [SVProgressHUD showErrorWithStatus:@"Error"];
                    }
                }];
            }
            else {
                [SVProgressHUD showErrorWithStatus:@"Error"];
            }
        }];
    }
}

- (void)setPhotoModel:(FRPPhotoModel *)photoModel photoIndex:(NSInteger)index
{
    self.photoModel = photoModel;
    self.photoIndex = index;
}

@end
