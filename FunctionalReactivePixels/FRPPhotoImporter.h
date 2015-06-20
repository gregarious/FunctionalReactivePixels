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

// don't need any completion blocks here because we have signals
// also, having the image data be part of the PhotoModel allows us to avoid explicit "downloadImage" methods. instead we can just listen for KVO signals for changes that are initiated inside these methods.

+ (RACSignal *)importPhotos;
+ (RACSignal *)fetchPhotoDetails:(FRPPhotoModel *)photoModel;

@end
