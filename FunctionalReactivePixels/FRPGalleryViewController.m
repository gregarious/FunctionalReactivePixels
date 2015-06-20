//
//  FRPGalleryViewController.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import "FRPGalleryFlowLayout.h"
#import "FRPCell.h"

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"

#import "FRPGalleryViewController.h"
#import "FRPFullSizePhotoViewController.h"

@interface FRPGalleryViewController () <FRPFullSizePhotoViewControllerDelegate>

@property (nonatomic, copy) NSArray *photosArray;

@end

@implementation FRPGalleryViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Popular on 500px";
    
    [self loadPopularPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPhotosArray:(NSArray *)photosArray
{
    _photosArray = [photosArray copy];
    [self.collectionView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFullSizePhoto"]) {
        FRPFullSizePhotoViewController *vc = segue.destinationViewController;

        FRPCell *selectedCell = sender;
        NSInteger selectedIndex = [[self.collectionView indexPathForCell:selectedCell] item];
        
        vc.delegate = self;
        [vc setPhotoModels:self.photosArray currentPhotoIndex:selectedIndex];
    }
}

#pragma mark - Private

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count;
}

#pragma mark <UICollectionViewDelegate>

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    FRPPhotoModel *model = self.photosArray[indexPath.row];
    [FRPPhotoImporter downloadThumbnailForPhotoModel:model completionBlock:^(NSData *data, NSError *error) {
        if (data) {
            [cell setThumbnailImage:[UIImage imageWithData:data]];
        }
        else {
            NSLog(@"Thumbnail error: %@", error);
        }
    }];
    return cell;
}

#pragma mark <FRPFullSizePhotoViewControllerDelegate>

- (void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                        animated:NO];
}

#pragma mark Helpers

- (void)loadPopularPhotos {
    [FRPPhotoImporter importPhotosWithCompletionBlock:^(NSArray *photos, NSError *err) {
        self.photosArray = photos;
        [self.collectionView reloadData];
    }];
}

@end
