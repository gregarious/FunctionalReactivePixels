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
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    NSURLRequest *request = [self popularURLRequest];
    
    [NSURLConnection
         sendAsynchronousRequest:request
         queue:[NSOperationQueue mainQueue]
         completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
             if (data) {
                 id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                 RACSequence *photosSequence = [results[@"photos"] rac_sequence];
                 [subject sendNext:[[photosSequence map:^id(NSDictionary *photoDictionary) {
                     FRPPhotoModel *model = [[FRPPhotoModel alloc] init];
                     [self configurePhotoModel:model withDictionary:photoDictionary];
                     [self downloadThumbnailForPhotoModel:model];
                     return model;
                 }] array]];
                 [subject sendCompleted];
             }
             else {
                 [subject sendError:connectionError];
             }
     }];
    
    return subject;
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
    
    return [[[[[array rac_sequence] filter:^BOOL(NSDictionary *value) {
        return [value[@"size"] integerValue] == size;
    }] map:^id(id value) {
        return value[@"url"];
    }] array] firstObject];
}

+ (void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel {
    NSAssert(photoModel.thumbnailURL, @"Thumbnail has no URL!");
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photoModel.thumbnailURL]];
    [NSURLConnection
        sendAsynchronousRequest:request
        queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            photoModel.thumbnailData = data;
        }];
}

@end