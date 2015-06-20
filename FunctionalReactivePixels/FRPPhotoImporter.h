//
//  FRPPhotoImporter.h
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal;

@interface FRPPhotoImporter : NSObject

+ (RACSignal *)importPhotos;

@end
