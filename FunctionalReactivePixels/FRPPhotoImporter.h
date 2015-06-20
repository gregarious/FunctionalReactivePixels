//
//  FRPPhotoImporter.h
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;
@class FRPPhotoModel;

@interface FRPPhotoImporter : NSObject

+ (RACSignal *)importPhotos;
+ (RACSignal *)fetchPhotoDetails:(FRPPhotoModel *)photoModel;

@end
