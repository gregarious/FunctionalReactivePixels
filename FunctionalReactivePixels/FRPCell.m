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
