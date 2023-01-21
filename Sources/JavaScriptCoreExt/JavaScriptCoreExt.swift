import JavaScriptCore
import Foundation

// let handle = dlopen("libobjc.dylib", RTLD_LAZY)
// let msgSend = dlsym(handle, "objc_msgSend")

public enum JSScriptType: Int32 {
    case program, module
}

// public class JSCExtScript {
//     var inner: Any
    
//     init(
//         ofType type: JSScriptType,
//         withSource source: String,
//         andSourceURL url: URL,
//         in vm: JSVirtualMachine
//     ) throws {
//         let cls = objc_getClass("JSScript")!
//         let sel = Selector(("scriptOfType:withSource:andSourceURL:andBytecodeCache:inVirtualMachine:error:"))
//         typealias Fn = @convention(c) (Any, Selector, CInt, NSString, NSURL, Any?, Any, UnsafeMutablePointer<NSError?>) -> Any
//         let fn = unsafeBitCast(msgSend, to: Fn.self)
//         let outError = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
//         inner = fn(
//             cls,
//             sel,
//             type.rawValue,
//             NSString(string: source),
//             NSURL(string: url.absoluteString)!,
//             nil,
//             vm,
//             outError
//         )
//         if let err = outError.pointee {
//             throw err
//         }
//     }
// }

@objc public protocol JSModuleLoaderDelegate {
    @objc func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!)
    
    @objc optional func willEvaluateModule(_ key: URL!)
    @objc optional func didEvaluateModule(_ key: URL!)
}

public extension JSContext {
    func setModuleLoaderDelegate(_ value: JSModuleLoaderDelegate) {
        self.perform(Selector(("setModuleLoaderDelegate:")), with: value)
    }
    
    // func evaluateJSScript(_ script: JSCExtScript) -> JSValue {
    //     return self.perform(Selector(("evaluateJSScript:")), with: script.inner).takeRetainedValue() as! JSValue
    // }
}
