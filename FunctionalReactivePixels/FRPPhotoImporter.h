//
//  FRPPhotoImporter.h
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRPPhotoModel;

@interface FRPPhotoImporter : NSObject

+ (void)importPhotosWithCompletionBlock:(void (^)(NSArray *photos, NSError* error))completion;
+ (void)fetchPhotoDetails:(FRPPhotoModel *)photoModel completionBlock:(void (^)(FRPPhotoModel *photo, NSError *error))completion;

+ (void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel completionBlock:(void (^)(NSData *data, NSError *error))completion;
+ (void)downloadFullsizedImageForPhotoModel:(FRPPhotoModel *)photoModel completionBlock:(void (^)(NSData *data, NSError *error))completion;

@end
