//
//  FRPCell.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import "FRPCell.h"

@interface FRPCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation FRPCell

- (void)setThumbnailImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end
