#import "CookiesSync.h"
#import <Cordova/CDVPlugin.h>
#import <WebKit/WebKit.h>

@implementation CookiesSync

- (void)executeXHR:(CDVInvokedUrlCommand *)command {

    if (@available(iOS 11.0, *)) {
        WKWebView* wkWebView = (WKWebView*) self.webView;
        NSString *domain = command.arguments[1];
        NSString *path = command.arguments[2];

        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:@"foo" forKey:NSHTTPCookieName];
        [cookieProperties setObject:@"bar" forKey:NSHTTPCookieValue];
        [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:domain forKey:NSHTTPCookieOriginURL];
        [cookieProperties setObject:path forKey:NSHTTPCookiePath];
        NSHTTPCookie * cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];

        [wkWebView.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{NSLog(@"Cookies synced");}];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId: command.callbackId];
    } else {
        @try {
            NSString *urlString = command.arguments[0];
            NSURL *url = [NSURL URLWithString:urlString];

            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
            [urlRequest setHTTPMethod:@"GET"];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];

            NSURLSession *urlSession = [NSURLSession sharedSession];

            [[urlSession dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                CDVPluginResult *result;

                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                NSHTTPURLResponse *httpResponse = nil;
                if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                    httpResponse = (NSHTTPURLResponse*)response;
                    dict[@"statusCode"] = [NSNumber numberWithInteger:httpResponse.statusCode];
                }
                if (data) {
                    dict[@"data"] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
                if (error) {
                    NSLog(@"executeXHR error: %@", error);
                    dict[@"error"] = [error localizedDescription];
                    if (httpResponse) {
                        NSLog(@"executeXHR error code: %d", (int)httpResponse.statusCode);
                    }
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:dict];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
                }
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }] resume];
        }
        @catch (NSException *exception) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:exception.reason];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }
    }
}

@end
