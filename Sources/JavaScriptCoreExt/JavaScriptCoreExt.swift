import JavaScriptCore
import Foundation

public enum JSScriptType: Int64 {
    case program, module
}

public class JSCExtScript {
    public var inner: Any
    
    public init(
        ofType type: JSScriptType,
        withSource source: String,
        andSourceURL url: URL,
        in vm: JSVirtualMachine
    ) throws {
        print("huh")
        let cls = objc_getClass("JSScript")!
        let sel = Selector(("scriptOfType:withSource:andSourceURL:andBytecodeCache:inVirtualMachine:error:"))
        let method = class_getClassMethod(cls as! AnyClass, sel)
        let imp = method_getImplementation(method!)
        typealias Fn = @convention(c) (Any, Selector, Int64, NSString, NSURL, NSURL?, JSVirtualMachine, UnsafeMutablePointer<NSError?>) -> Any
        let fn = unsafeBitCast(imp, to: Fn.self)
        let outError = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
        inner = fn(
            cls,
            sel,
            type.rawValue,
            source as NSString,
            url as NSURL,
            nil,
            vm,
            outError
        )
        if let err = outError.pointee {
            throw err
        }
    }
}

@objc public protocol JSModuleLoaderDelegate {
    @objc func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!)
    
    @objc optional func willEvaluateModule(_ key: URL!)
    @objc optional func didEvaluateModule(_ key: URL!)
}

public extension JSContext {
    func setModuleLoaderDelegate(_ value: JSModuleLoaderDelegate) {
        self.perform(Selector(("setModuleLoaderDelegate:")), with: value)
    }
    
    func evaluateJSScript(_ script: JSCExtScript) -> JSValue {
        return self.perform(Selector(("evaluateJSScript:")), with: script.inner).takeRetainedValue() as! JSValue
    }
}
