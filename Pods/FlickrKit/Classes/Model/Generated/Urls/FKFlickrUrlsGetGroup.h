//
//  FKFlickrUrlsGetGroup.h
//  FlickrKit
//
//  Generated by FKAPIBuilder on 12 Jun, 2013 at 17:19.
//  Copyright (c) 2013 DevedUp Ltd. All rights reserved. http://www.devedup.com
//
//  DO NOT MODIFY THIS FILE - IT IS MACHINE GENERATED


#import "FKFlickrAPIMethod.h"

typedef enum {
	FKFlickrUrlsGetGroupError_GroupNotFound = 1,		 /* The NSID specified was not a valid group. */
	FKFlickrUrlsGetGroupError_InvalidAPIKey = 100,		 /* The API key passed was not valid or has expired. */
	FKFlickrUrlsGetGroupError_ServiceCurrentlyUnavailable = 105,		 /* The requested service is temporarily unavailable. */
	FKFlickrUrlsGetGroupError_FormatXXXNotFound = 111,		 /* The requested response format was not found. */
	FKFlickrUrlsGetGroupError_MethodXXXNotFound = 112,		 /* The requested method was not found. */
	FKFlickrUrlsGetGroupError_InvalidSOAPEnvelope = 114,		 /* The SOAP envelope send in the request could not be parsed. */
	FKFlickrUrlsGetGroupError_InvalidXMLRPCMethodCall = 115,		 /* The XML-RPC request document could not be parsed. */
	FKFlickrUrlsGetGroupError_BadURLFound = 116,		 /* One or more arguments contained a URL that has been used for abuse on Flickr. */

} FKFlickrUrlsGetGroupError;

/*

Returns the url to a group's page.


Response:

<group nsid="48508120860@N01" url="http://www.flickr.com/groups/test1/" /> 

*/
@interface FKFlickrUrlsGetGroup : NSObject <FKFlickrAPIMethod>

/* The NSID of the group to fetch the url for. */
@property (nonatomic, strong) NSString *group_id; /* (Required) */


@end
