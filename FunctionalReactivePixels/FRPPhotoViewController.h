//
//  FRPPhotoViewController.h
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRPPhotoModel.h"

@interface FRPPhotoViewController : UIViewController

@property (nonatomic, readonly) NSInteger photoIndex;

- (void)setPhotoModel:(FRPPhotoModel *)photoModel photoIndex:(NSInteger)index;

@end
