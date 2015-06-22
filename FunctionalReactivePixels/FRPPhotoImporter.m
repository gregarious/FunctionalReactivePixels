//
//  FRPPhotoImporter.m
//  FunctionalReactivePixels
//
//  Created by Greg Nicholas on 6/19/15.
//  Copyright (c) 2015 Gregarious Development. All rights reserved.
//

#import <500px-iOS-api/PXAPI.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"

@interface FRPPhotoImporter ()
@end

@implementation FRPPhotoImporter

+ (RACSignal *)importPhotos {
    
    // Notes about the methods used here:
    // 1. reduceEach:   Allows us to unpack a tuple in the block arguments. No real compiler checking going on here, but it helps readability.
    // 2. publish       Wraps the network signal in a multicast signal. This indirection ensures the network signal will only have one subscriber (and therefore only do its work once), but be able to be broadcast to any number of subscribers.
    // 3. autoconnect:  Our multicast won't subscribe to it's underlying signal until it itself has a subscriber (it's cold). Since we don't have that subscriber on hand yet, but we do want our network call to start now, we force it to be hot with this call.
    
    NSURLRequest *request = [self popularURLRequest];
    return [[[[[NSURLConnection rac_sendAsynchronousRequest:request]
                reduceEach:^id(NSURLResponse *respone, NSData *data) {
                   return data;
                }]
                map:^id(id data) {
                    id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    return [[[results[@"photos"] rac_sequence] map:^id(NSDictionary *photoDictionary) {
                        FRPPhotoModel *model = [[FRPPhotoModel alloc] init];
                        [self configurePhotoModel:model withDictionary:photoDictionary];
                        [self downloadThumbnailForPhotoModel:model];
                        return model;
                    }] array];
                }] publish] autoconnect];
}

+ (RACSignal *)fetchPhotoDetails:(FRPPhotoModel *)photoModel
{
    NSURLRequest *request = [self photoURLRequest:photoModel];
    
    return [[[[[NSURLConnection rac_sendAsynchronousRequest:request]
                reduceEach:^id(NSURLResponse *respone, NSData *data) {
                    return data;
                }]
                map:^id(NSData *data) {
                    id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
                    [self configurePhotoModel:photoModel withDictionary:results];
                    [self downloadFullsizedImageForPhotoModel:photoModel];
                    return photoModel;
                }] publish] autoconnect];
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
    
    // functional way of returning the first url of the given size. don't really this this has any advantages of declarative version. in fact, IMO the declarative for-in loop is more readable in ObjC
    return [[[[[array rac_sequence] filter:^BOOL(NSDictionary *value) {
        return [value[@"size"] integerValue] == size;
    }] map:^id(id value) {
        return value[@"url"];
    }] array] firstObject];
}

+ (void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel {
    RAC(photoModel, thumbnailData) = [self download:photoModel.thumbnailURL];
}

+ (void)downloadFullsizedImageForPhotoModel:(FRPPhotoModel *)photoModel {
    RAC(photoModel, fullsizedData) = [self download:photoModel.fullsizedURL];
}

+ (RACSignal *)download:(NSString *)urlString
{
    NSAssert(urlString, @"URL must not be nil");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    return [[NSURLConnection rac_sendAsynchronousRequest:request]
            map:^id(RACTuple *responseTuple) {
                return responseTuple.second;
            }];
}

@end
