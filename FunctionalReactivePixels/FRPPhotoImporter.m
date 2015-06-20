//
//  FRPPhotoImporter.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <500px-iOS-api/PXAPI.h>

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"

@interface FRPPhotoImporter ()
@end

@implementation FRPPhotoImporter

+ (void)importPhotosWithCompletionBlock:(void (^)(NSArray *photos, NSError *error))completion
{
    NSURLRequest *request = [self popularURLRequest];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (data) {
             id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
             NSArray *rawPhotos = results[@"photos"];

             NSMutableArray *photos = [NSMutableArray arrayWithCapacity:rawPhotos.count];
             for (NSDictionary *photoDictionary in results[@"photos"]) {
                 FRPPhotoModel *model = [[FRPPhotoModel alloc] init];
                 [self configurePhotoModel:model withDictionary:photoDictionary];
                 [photos addObject:model];
             }
             completion(photos, nil);
         }
         else {
             completion(nil, connectionError);
         }
     }];
}

+ (void)fetchPhotoDetails:(FRPPhotoModel *)photoModel completionBlock:(void (^)(FRPPhotoModel *photo, NSError *error))completion
{
    NSURLRequest *request = [self photoURLRequest:photoModel];
    
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         if (data) {
             id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
             [self configurePhotoModel:photoModel withDictionary:results];
             completion(photoModel, nil);
         }
         else {
             completion(nil, connectionError);
         }
     }];
}

+ (PXAPIHelper *)systemAPIHelper
{
    static PXAPIHelper *helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[PXAPIHelper alloc] initWithHost:nil consumerKey:@"eWKB1D3eNgPUpO8SaWL6V6MMipY7etm4MPSMEwiv" consumerSecret:@"ImoESvNYu6bbR16y9VnvZ8ItzcR9gyHgf4eWx2UO"];
    });
    return helper;
}

+ (NSURLRequest *)popularURLRequest {
    return [self.systemAPIHelper urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:100 page:0 photoSizes:PXPhotoModelSizeThumbnail sortOrder:PXAPIHelperSortOrderRating except:PXPhotoModelCategoryNude];
}
     
+(NSURLRequest *)photoURLRequest:(FRPPhotoModel *)photoModel {
    return [self.systemAPIHelper urlRequestForPhotoID:photoModel.identifier.integerValue];
}

+ (void)configurePhotoModel:(FRPPhotoModel *)photoModel withDictionary:(NSDictionary *)dictionary {
    // Basics details fetched with the first, basic request
    photoModel.photoName = dictionary[@"name"];
    photoModel.identifier = dictionary[@"id"];
    photoModel.photographerName = dictionary[@"user"][@"username"];
    photoModel.rating = dictionary[@"rating"];
    
    photoModel.thumbnailURL = [self urlForImageSize:3 inArray:dictionary[@"images"]];
    
    if (dictionary[@"voted"]) {
        photoModel.votedFor = [dictionary[@"voted"] boolValue];
    }
    
    // Extended attributes fetched with subsequent request
    if (dictionary[@"comments_count"]) {
        photoModel.fullsizedURL = [self urlForImageSize:4 inArray:dictionary[@"images"]];
    }
}

+ (NSString *)urlForImageSize:(NSInteger)size inArray:(NSArray *)array {
    /*
     (
     {
     size = 3;
     url = "http://ppcdn.500px.org/49204370/b125a49d0863e0ba05d8196072b055876159f33e/3.jpg";
     }
     );
     */
    
    for (NSDictionary *imageAttr in array) {
        if ([imageAttr[@"size"] integerValue] == size) {
            return imageAttr[@"url"];
        }
    }
    return nil;
}

+ (void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel completionBlock:(void (^)(NSData *, NSError *))completion {
    [self download:photoModel.thumbnailURL withCompletion:^(NSData *data, NSError *error) {
        completion(data, error);
    }];
}

+ (void)downloadFullsizedImageForPhotoModel:(FRPPhotoModel *)photoModel completionBlock:(void (^)(NSData *, NSError *))completion {
    [self download:photoModel.fullsizedURL withCompletion:^(NSData *data, NSError *error) {
        completion(data, error);
    }];
}

+ (void)download:(NSString *)urlString withCompletion:(void(^)(NSData *data, NSError *error))completion
{
    NSAssert(urlString, @"URL must not be nil");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[NSOperationQueue mainQueue]
     completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
         completion(data, connectionError);
     }];
}

@end
