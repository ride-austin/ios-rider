//
//  RANetworkManager.m
//  RideDriver
//
//  Created by Carlos Alcala on 8/12/16.
//  Copyright © 2016 FuelMe LLC. All rights reserved.
//

#import "RANetworkManager.h"

#import "ConfigurationManager.h"
#import "ErrorReporter.h"
#import "NSError+ErrorFactory.h"
#import "RADeviceCheck.h"
#import "RAEnvironmentManager.h"
#import "RANetworkManagerQueues.h"
#import "RASessionManager.h"
#import "TestManager.h"
#import "UIDevice+Model.h"
#import "URLFactory.h"

#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <BugfenderSDK/BugfenderSDK.h>

static NSString *const kAuthTokenHttpHeaderField = @"X-Auth-Token";
static NSString *const kApiKeyHttpHeaderField = @"X-Api-Key";

BOOL isJailbroken()
{
#if !(TARGET_IPHONE_SIMULATOR)
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"] ||
        [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"] ||
        [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])  {
        return YES;
    }
    
    FILE *f = NULL ;
    if ((f = fopen("/bin/bash", "r")) ||
        (f = fopen("/Applications/Cydia.app", "r")) ||
        (f = fopen("/Library/MobileSubstrate/MobileSubstrate.dylib", "r")) ||
        (f = fopen("/usr/sbin/sshd", "r")) ||
        (f = fopen("/etc/apt", "r")))  {
        fclose(f);
        return YES;
    }
    fclose(f);
    
    NSError *error;
    NSString *stringToBeWritten = @"This is a test.";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    if(error == nil)
    {
        return YES;
    }
    
#endif
    
    return NO;
}

@interface RANetworkManager ()

@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSString *userPlatform;
@property (nonatomic, strong) NSString *userModel;
@property (nonatomic, strong) NSString *userUUID;
@property (nonatomic, strong) NSString *userDeviceName;

@property(nonatomic, strong) AFHTTPSessionManager *formURLClient;
@property(nonatomic, strong) AFHTTPSessionManager *jsonClient;

@property (nonatomic, getter=isSimulatingNetworkStatus) BOOL simulatingNetworkStatus;
@property (nonatomic) RANetworkStatusSimulation simulatedNetworkStatus;
@property (nonatomic, strong) NSMutableDictionary<NSString*, RANetworkReachabilityBlock> *reachabilityHandlers;
@property (nonatomic) RANetworkReachability lastReachability;

@property (nonatomic) NSMutableDictionary<NSString *, dispatch_queue_t> *completionQueues;
@property (nonatomic) NSMutableDictionary<NSString *, AFHTTPSessionManager *> *serialClients;

@end

@interface RANetworkManager (BaseRequests)

- (void)request:(RAMethod)type
           path:(NSString*)path
         client:(AFHTTPSessionManager*)client
     parameters:(id)parameters
        success:(NetworkSuccessBlock)success
        failure:(NetworkFailureBlock)failure;

@end

@interface RANetworkManager (Tracker)

+ (void)trackResponse:(NSString*)path;

@end

@interface RANetworkManager (ClientConstructor)

- (AFHTTPSessionManager *)clientForParameterEncoding:(RAClientParameterEncoding)encoding;
- (AFHTTPSessionManager *)clientWithName:(NSString *)clientName forParameterEncoding:(RAClientParameterEncoding)parameterEncoding;

@end

@interface RANetworkManager (Reachability_Private)

- (void)setUpReachability;
- (void)removeReachability;
- (void)notifyNetworkReachability:(RANetworkReachability)reachability;

@end

@interface RANetworkManager (Private)

- (void)processError:(NSError *)error withNetworkTask:(NSURLSessionTask *)networkTask errorDomain:(ERDomain)errorDomain andFailureBlock:(NetworkFailureBlock)failureHandler;

@end

@interface RANetworkManager (QueueFactory)

- (dispatch_queue_t)queueForType:(NSString *)queueType;

@end

@interface NSObject (Key)

@property (nonatomic, readonly) NSString* key;

@end

@implementation RANetworkManager

+ (RANetworkManager*)sharedManager {
    static RANetworkManager *networkManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[self alloc] init];
    });
    
    return networkManager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.simulatingNetworkStatus = NO;
        UIDevice *currentDevice = [UIDevice currentDevice];
        NSString *appName = [[ConfigurationManager localAppName] stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.userAgent = [NSString stringWithFormat:@"%@_iOS_%@",appName,[[RAEnvironmentManager sharedManager] completeVersion]];
        self.userPlatform = [[currentDevice systemName] stringByAppendingFormat:@" %@",[currentDevice systemVersion]];
        self.userModel = [currentDevice modelType] ?: [currentDevice model];
        self.userUUID = [RADeviceCheck deviceIdentifier];
        
        if (isJailbroken()) {
            self.userDeviceName = [NSString stringWithFormat:@"%@_JB_",currentDevice.name];
        } else {
            self.userDeviceName = currentDevice.name;
        }
        
        self.serialClients = [NSMutableDictionary new];
        [self reloadBaseURL];
        [self setUpReachability];
        self.completionQueues = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc{
    [self removeReachability];
}

- (void)setAuthToken:(NSString *)authToken{
    _authToken = authToken;
    
    [self.formURLClient.requestSerializer clearAuthorizationHeader];
    [self.formURLClient.requestSerializer setValue:authToken forHTTPHeaderField:kAuthTokenHttpHeaderField];
    
    [self.jsonClient.requestSerializer clearAuthorizationHeader];
    [self.jsonClient.requestSerializer setValue:authToken forHTTPHeaderField:kAuthTokenHttpHeaderField];
    
    for (AFHTTPSessionManager *client in self.serialClients) {
        [client.requestSerializer clearAuthorizationHeader];
        [client.requestSerializer setValue:authToken forHTTPHeaderField:kAuthTokenHttpHeaderField];
    }
}

- (BOOL)isAuthenticated{
    return self.authToken != nil;
}

- (void)reloadBaseURL{
    self.baseURL = [RAEnvironmentManager sharedManager].serverUrl;
    self.formURLClient = [self clientForParameterEncoding:FORM];
    self.jsonClient    = [self clientForParameterEncoding:JSON];
    [self.serialClients removeAllObjects];
}

- (void)cancelAllOperations{
    [[self.formURLClient operationQueue] cancelAllOperations];
    [[self.jsonClient    operationQueue] cancelAllOperations];
    for (AFHTTPSessionManager *client in self.serialClients) {
        [client.operationQueue cancelAllOperations];
    }
}

@end

#pragma mark - Requests
#pragma mark -

@implementation RANetworkManager (Requests)

- (void)executeRequest:(RARequest *)request {
    
    dispatch_queue_t mappingQueue = [self queueForType:request.mappingQueueType];
    AFHTTPSessionManager *client = [self clientWithName:request.clientName forParameterEncoding:request.parameterEncoding];
    
    if (request.useAuthorizationHeader) {
        [client.requestSerializer setAuthorizationHeaderFieldWithUsername:request.username password:request.password];
    }

    __weak RANetworkManager *weakSelf = self;
    if ([request isKindOfClass:[RAMultipartRequest class]]) {
        RAMultipartRequest *mpRequest = (RAMultipartRequest*)request;
        [self.jsonClient POST:mpRequest.path parameters:mpRequest.parameters constructingBodyWithBlock:mpRequest.body progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (mpRequest.success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    mpRequest.success(task, responseObject);
                });
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf processError:error withNetworkTask:task errorDomain:mpRequest.errorDomain andFailureBlock:mpRequest.failure];
        }];
        
    } else {
        [self request:request.method path:request.path client:client parameters:request.parameters success:^(NSURLSessionTask *networkTask, id response) {
            if (request.mapping) {
                dispatch_async(mappingQueue, ^{
                    id responseMapping = request.mapping(response);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        request.success(networkTask, responseMapping);
                    });
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    request.success(networkTask, response);
                });
            }
        } failure:^(NSURLSessionTask *networkTask, NSError *error) {
            [weakSelf processError:error withNetworkTask:networkTask errorDomain:request.errorDomain andFailureBlock:request.failure];
        }];
    }
}

@end

#pragma mark - Base Requests

@implementation RANetworkManager (BaseRequests)

- (void)request:(RAMethod)type path:(NSString *)path client:(AFHTTPSessionManager*)client parameters:(id)parameters success:(NetworkSuccessBlock)success failure:(NetworkFailureBlock)failure {
    switch (type) {
        case GET:
            [client GET:path parameters:parameters progress:nil success:success failure:failure];
            break;
            
        case POST:
            [client POST:path parameters:parameters progress:nil success:success failure:failure];
            break;
            
        case PUT:
            [client PUT:path parameters:parameters success:success failure:failure];
            break;
            
        case DELETE:
            [client DELETE:path parameters:parameters success:success failure:failure];
            break;
    }
}

@end

#pragma mark - Tracker

@implementation RANetworkManager (Tracker)

+ (void)trackResponse:(NSString*)path {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Network" action:@"NetworkResponse" label:path value:nil] build]];
}

@end

#pragma mark - Device Information
#pragma mark -
#import "AppConfig.h"

static NSString *const kAcceptHttpHeaderField = @"Accept";
static NSString *const kContentTypeHttpHeaderField = @"Content-type";
static NSString *const kAcceptVersionHttpHeaderField = @"Accept-Version";
static NSString *const kUserAgentHttpHeaderField = @"User-Agent";
static NSString *const kUserPlatformHttpHeaderField = @"User-Platform";
static NSString *const kUserDeviceHttpHeaderField = @"User-Device";
static NSString *const kUserDeviceIDHttpHeaderField = @"User-Device-Id";
static NSString *const kUserDeviceOtherHttpHeaderField = @"User-Device-Other";

@implementation RANetworkManager (ClientConstructor)

- (AFHTTPSessionManager *)clientForParameterEncoding:(RAClientParameterEncoding)encoding {
    AFHTTPSessionManager *client = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.baseURL]];
    AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;
    if (encoding == JSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    } else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    [requestSerializer setValue:@"application/json, image/png, */*" forHTTPHeaderField:kAcceptHttpHeaderField];
    [requestSerializer setValue:[AppConfig apiKey] forHTTPHeaderField:kApiKeyHttpHeaderField];
    [requestSerializer setValue:@"1.0.0" forHTTPHeaderField:kAcceptVersionHttpHeaderField];
    [requestSerializer setValue:self.userAgent forHTTPHeaderField:kUserAgentHttpHeaderField];
    [requestSerializer setValue:self.userPlatform forHTTPHeaderField:kUserPlatformHttpHeaderField];
    [requestSerializer setValue:self.userModel forHTTPHeaderField:kUserDeviceHttpHeaderField];
    [requestSerializer setValue:self.userUUID forHTTPHeaderField:kUserDeviceIDHttpHeaderField];
    [requestSerializer setValue:self.userDeviceName forHTTPHeaderField:kUserDeviceOtherHttpHeaderField];
    [requestSerializer setValue:self.authToken forHTTPHeaderField:kAuthTokenHttpHeaderField];
    client.requestSerializer = requestSerializer;
    client.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    return client;
}

- (AFHTTPSessionManager *)clientWithName:(NSString *)clientName forParameterEncoding:(RAClientParameterEncoding)parameterEncoding{
    if (clientName) {
        AFHTTPSessionManager *client = self.serialClients[clientName];
        if (client == nil) {
            client = [self clientForParameterEncoding:parameterEncoding];
            client.operationQueue.maxConcurrentOperationCount = 1;
            self.serialClients[clientName] = client;
        }
        return client;
    } else {
        switch (parameterEncoding) {
            case FORM:  return self.formURLClient;
            case JSON:  return self.jsonClient;
        }
    }
}

@end

#pragma mark - Reachability

@implementation RANetworkManager (Reachability)

- (BOOL)isNetworkReachable {
    if ([self isSimulatingNetworkStatus]) {
        switch (self.simulatedNetworkStatus) {
            case RASimNetUnreachableStatus:
                return NO;
                break;
                
            default:
                return YES;
                break;
        }
    } else {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
}

- (void)addReachabilityObserver:(NSObject *)observer statusChangedBlock:(RANetworkReachabilityBlock)handler {
    self.reachabilityHandlers[observer.key] = handler;
}

- (void)removeReachabilityObserver:(NSObject *)observer {
    [self.reachabilityHandlers removeObjectForKey:observer.key];
}

- (void)simulateNetworkStatus:(RANetworkStatusSimulation)networkStatus {
    self.simulatingNetworkStatus = YES;
    self.simulatedNetworkStatus = networkStatus;
    
    RANetworkReachability reachability = RANetworkReachable;
    switch (networkStatus) {
        case RASimNetUnreachableStatus:
            reachability = RANetworkNotReachable;
            break;
        default:
            break;
    }
    
    [self notifyNetworkReachability:reachability];
}

- (void)disableNetworkStatusSimualation {
    self.simulatingNetworkStatus = NO;
    [self notifyNetworkReachability:self.lastReachability];
}


@end

#pragma mark - Reachability Private

@implementation RANetworkManager (Reachability_Private)

- (void)setUpReachability {
    self.reachabilityHandlers = [NSMutableDictionary dictionary];
    self.lastReachability = [self isNetworkReachable] ? RANetworkReachable : RANetworkNotReachable;
    
    __weak RANetworkManager *weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        RANetworkReachability reachability = (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) ? RANetworkNotReachable : RANetworkReachable;
        if (weakSelf.lastReachability != reachability) {
            weakSelf.lastReachability = reachability;
            BFLogWarn(@"Network reachability changed to: %@", reachability == RANetworkReachable ? @"Reachable" : @"Not reachable");
            
            if (![weakSelf isSimulatingNetworkStatus]) {
                [weakSelf notifyNetworkReachability:reachability];
            }
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)removeReachability {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:nil];
    [self.reachabilityHandlers removeAllObjects];
    self.reachabilityHandlers = nil;
}

- (void)notifyNetworkReachability:(RANetworkReachability)reachability {
    for (RANetworkReachabilityBlock handler in self.reachabilityHandlers.allValues) {
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(reachability);
        });
    }
}

@end

#pragma mark - Private

@implementation RANetworkManager (Private)

- (void)processError:(NSError *)error withNetworkTask:(NSURLSessionTask *)networkTask errorDomain:(ERDomain)errorDomain andFailureBlock:(NetworkFailureBlock)failureHandler {
    NSError *filteredError = error.filteredError;
    
    [self recordError:filteredError fromNetworkTask:networkTask withErrorDomain:errorDomain];
    
    if ([self shouldHandle401FromNetworkTask:networkTask]) {
        [self handle401FromNetworkTask:networkTask];
    }
    
    if (failureHandler) {
        failureHandler(networkTask, filteredError);
    }
}

- (BOOL)shouldHandle401FromNetworkTask:(NSURLSessionTask *)networkTask {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)networkTask.response;
    if (!httpResponse) {
        return NO;
    }
    return httpResponse.statusCode == 401;
}

- (void)handle401FromNetworkTask:(NSURLSessionTask *)networkTask {
    RASessionManager *manager = [RASessionManager sharedManager];
    NSURL *currentURL = networkTask.currentRequest.URL;
    if ([currentURL.absoluteString hasSuffix:kPathLogout]) {
        [manager clearCurrentSession]; //clear session only
    } else if ([currentURL.path hasSuffix:kPathLogin]) {
        [manager clearHeader]; //clear header only
    } else {
        [manager logoutWithCompletion:nil]; //completely logout
    }
}

- (void)recordError:(NSError *)error fromNetworkTask:(NSURLSessionTask *)networkTask withErrorDomain:(ERDomain)errorDomain {
    NSString *path = networkTask.currentRequest.URL.absoluteString;
    NSRange range = [path rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        path = [path substringToIndex:range.location];
        path = [path stringByReplacingOccurrencesOfString:self.baseURL withString:@""];
    }
    
    if (errorDomain == UnspecifiedDomain) {
        NSString *domain = [NSString stringWithFormat:@"%@_%@",networkTask.currentRequest.HTTPMethod,path];
        [ErrorReporter recordError:error withCustomDomainName:domain];
    } else {
        [ErrorReporter recordError:error withDomainName:errorDomain];
    }
}

@end

@implementation RANetworkManager (QueueFactory)

- (dispatch_queue_t)queueForType:(NSString *)queueType {
    if ([QueueTypeUserInteractive isEqualToString:queueType]) {
        return dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    } else if ([QueueTypeUserInitiated isEqualToString:queueType]) {
        return dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    } else if ([QueueTypeUtility isEqualToString:queueType]) {
        return dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
    } else if ([QueueTypeBackground isEqualToString:queueType]) {
        return dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
    } else if ([QueueTypeDefault isEqualToString:queueType]) {
        return dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);
    } else if (queueType == nil || [QueueTypeMainQueue isEqualToString:queueType]) {
        return dispatch_get_main_queue();
    } else {
        return [self serialQueueForName:queueType];
    }
}

- (dispatch_queue_t)serialQueueForName:(NSString *)queueName {
    dispatch_queue_t queue = self.completionQueues[queueName];
    if (queue == nil) {
        dispatch_queue_attr_t queueAttrs = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0);
        queue = dispatch_queue_create(queueName.UTF8String, queueAttrs);
        self.completionQueues[queueName] = queue;
    }
    return queue;
}

@end

#pragma mark - NSObject key

@implementation NSObject (Key)

-(NSString *)key{
    return [NSString stringWithFormat:@"%lu", (unsigned long)self.hash];
}

@end

