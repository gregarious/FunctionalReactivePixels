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

@end

@implementation FRPCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self commonInit];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self commonInit];
    return self;
}

- (void)commonInit
{
    // Directly bind our cell's image to a signal that will fire on *both* ViewModel and ViewModel image data changes. This way, the image responds to both data download completion and the overwriting of self.photoModel (which happens during cell reuse). This obviates the need for manually disposing of a particular model's signal on cell reuse
    // Also note that we bind to self, not to self.imageView, because the imageView is currently nil. The TARGET argument must always be non-nil to correctly initialize a signal.
    // Further note that I modified the books version here, removing the nil filter: if we don't have data yet, we want our signal to tell us so
    RAC(self, imageView.image) = [RACObserve(self, photoModel.thumbnailData)
                                  map:^id(NSData *data) {
                                      return data != nil ? [UIImage imageWithData:data] : nil;
                                  }];
}

@end
