//
//  FRPGalleryViewController.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <libextobjc/EXTScope.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACDelegateProxy.h>

#import "FRPGalleryFlowLayout.h"
#import "FRPCell.h"

#import "FRPPhotoImporter.h"

#import "FRPGalleryViewController.h"
#import "FRPFullSizePhotoViewController.h"

@interface FRPGalleryViewController ()

@property (nonatomic, strong) NSArray *photosArray;
@property (nonatomic, strong) RACDelegateProxy *viewControllerDelegate;

@end

@implementation FRPGalleryViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Popular on 500px";

    /* ReactiveCocoa Setup */
    
    @weakify(self);

    // set up a delegation signal for the FullSize VC's delegation method
    self.viewControllerDelegate = [[RACDelegateProxy alloc] initWithProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)];
    [[self.viewControllerDelegate rac_signalForSelector:@selector(userDidScroll:toPhotoAtIndex:) fromProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)]
        subscribeNext:^(RACTuple *value) {
            @strongify(self);
            NSInteger index = [value.second integerValue];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]
                                        atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                animated:NO];
        }];
    
    
    // create a pass-through signal for the photo importer signal that handles the error, then directly bind the photosArray state to the signal
    RACSignal *photoSignal = [FRPPhotoImporter importPhotos];
    RACSignal *photosLoaded = [[photoSignal catch:^RACSignal *(NSError *error) {
        NSLog(@"Could not load photos from 550px: %@", error);
        return photoSignal;
    }] deliverOn:[RACScheduler mainThreadScheduler]];
    // Note: catch: is similar to subscribeError: except that it lets non-errors pass through. Also, on error, it allows us to pass along a new signal to take the place of the errored one (though here we just want to complete the original signal)
    
    RAC(self, photosArray) = photosLoaded;
    [photosLoaded subscribeCompleted:^{
        @strongify(self);
        [self.collectionView reloadData];
    }];
    
    // more concise version, with default error logging:
//    RAC(self, photosArray) = [[[[FRPPhotoImporter importPhotos]
//        doCompleted:^{
//            @strongify(self);
//            [self.collectionView reloadData];
//        }] logError] catchTo:[RACSignal empty]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showFullSizePhoto"]) {
        FRPFullSizePhotoViewController *vc = segue.destinationViewController;

        FRPCell *selectedCell = sender;
        NSInteger selectedIndex = [[self.collectionView indexPathForCell:selectedCell] item];
        vc.delegate = (id<FRPFullSizePhotoViewControllerDelegate>)self.viewControllerDelegate;
        
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

    // just need the set the view-model once. the cell can take it from there getting triggers for when it should update its content
    [cell setPhotoModel:self.photosArray[indexPath.row]];

    return cell;
}

@end
