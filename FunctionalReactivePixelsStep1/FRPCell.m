//
//  FRPCell.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import "FRPCell.h"
#import "FRPPhotoModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface FRPCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) RACDisposable *subscription;

@end

@implementation FRPCell

- (void)setPhotoModel:(FRPPhotoModel *)photoModel
{
    // this manually does the work of the RAC macro:
    //  1. creates (and persists) a subscription to the photoModel.thumbnailData observe signal
    //  2. binds the signal result to our imageView.image keypath
    //
    // we don't use RAC here because we need to keep a reference to the subscription for the sake of manually disposing it upon cell reuse
    self.subscription = [[[RACObserve(photoModel, thumbnailData)
                            filter:^BOOL(id value) {
                                return value != nil;
                            }]
                            map: ^id(id value) {
                                return [UIImage imageWithData:value];
                            }]
                            setKeyPath:@keypath(self.imageView, image)
                              onObject:self.imageView];
}

- (void)prepareForReuse
{
    [self.subscription dispose];
    self.subscription = nil;
}
@end
