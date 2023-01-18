#import <objc/runtime.h>
#import <objc/message.h>
#import "libJavaScriptCoreExt.h"

@implementation JSCExtScript

+ (nullable id)scriptOfType:(JSScriptType)type withSource:(NSString * _Nonnull)source andSourceURL:(NSURL * _Nonnull)sourceURL andBytecodeCache:(nullable NSURL *)cachePath inVirtualMachine:(JSVirtualMachine * _Nonnull)vm error:(out NSError* _Nullable * _Nullable)error {
    Class cls = objc_getClass("JSScript");
    SEL sel = NSSelectorFromString(@"scriptOfType:withSource:andSourceURL:andBytecodeCache:inVirtualMachine:error:");
    id (*func)(id, SEL, JSScriptType, NSString *, NSURL *, NSURL *, JSVirtualMachine *, NSError **) = (id (*)(id, SEL, JSScriptType, NSString *, NSURL *, NSURL *, JSVirtualMachine *, NSError **))objc_msgSend;
    return func(cls, sel, type, source, sourceURL, cachePath, vm, error);
}

@end
