#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class JSVirtualMachine;

typedef NS_ENUM(NSInteger, JSScriptType) {
    kJSScriptTypeProgram,
    kJSScriptTypeModule,
};

// @interface JSScript : NSObject

// + (nullable instancetype)scriptOfType:(JSScriptType)type withSource:(NSString * _Nonnull)source andSourceURL:(NSURL * _Nonnull)sourceURL andBytecodeCache:(nullable NSURL *)cachePath inVirtualMachine:(JSVirtualMachine * _Nonnull)vm error:(out NSError* _Nullable * _Nullable)error;

// @end

@interface JSCExtScript : NSObject

+ (nullable instancetype)scriptOfType:(JSScriptType)type withSource:(NSString * _Nonnull)source andSourceURL:(NSURL * _Nonnull)sourceURL andBytecodeCache:(nullable NSURL *)cachePath inVirtualMachine:(JSVirtualMachine * _Nonnull)vm error:(out NSError* _Nullable * _Nullable)error;

@end

@protocol JSModuleLoaderDelegate <NSObject>

@required

- (void)context:(JSContext *)context fetchModuleForIdentifier:(JSValue *)identifier withResolveHandler:(JSValue *)resolve andRejectHandler:(JSValue *)reject;

@optional

- (void)willEvaluateModule:(NSURL *)key;

- (void)didEvaluateModule:(NSURL *)key;

@end

@interface JSContext (JSCExt)

@property (nonatomic, weak) id <JSModuleLoaderDelegate> moduleLoaderDelegate;

- (JSValue *)evaluateJSScript:(id)script;

@end
