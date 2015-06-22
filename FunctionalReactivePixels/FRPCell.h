//
//  FRPCell.h
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRPPhotoModel;

@interface FRPCell : UICollectionViewCell

// using view model here -- controller doesn't need to know details about what the view needs
@property (nonatomic, strong) FRPPhotoModel *photoModel;

@end
