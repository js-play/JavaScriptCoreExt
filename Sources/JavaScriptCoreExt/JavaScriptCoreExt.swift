import JavaScriptCore
import Foundation

public enum JSScriptType: Int64 {
    case program, module
}

public func JSCExtScript(
        of type: JSScriptType,
        withSource source: String,
        andSourceURL url: URL,
        in vm: JSVirtualMachine
) throws -> Any {
    let cls = objc_getClass("JSScript")!
    let sel = Selector(("scriptOfType:withSource:andSourceURL:andBytecodeCache:inVirtualMachine:error:"))
    let method = class_getClassMethod((cls as! AnyClass), sel)
    let imp = method_getImplementation(method!)
    typealias Fn = @convention(c) (Any, Selector, Int64, NSString, NSURL, NSURL?, JSVirtualMachine, UnsafeMutablePointer<NSError?>) -> Any?
    let fn = unsafeBitCast(imp, to: Fn.self)
    let outError = UnsafeMutablePointer<NSError?>.allocate(capacity: 1)
    let result = fn(
        cls,
        sel,
        type.rawValue,
        source as NSString,
        url as NSURL,
        nil,
        vm,
        outError
    )
    if result == nil {
        throw outError.pointee!
    }
    return result!
}

@objc public protocol JSModuleLoaderDelegate: NSObjectProtocol {
    @objc func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!)
    
    @objc optional func willEvaluateModule(_ key: URL!)
    @objc optional func didEvaluateModule(_ key: URL!)
}

public extension JSContext {
    var moduleLoaderDelegate: JSModuleLoaderDelegate {
        get {
            return self.perform(Selector(("moduleLoaderDelegate"))).takeRetainedValue() as! JSModuleLoaderDelegate
        }
        set(loader) {
            self.perform(Selector(("setModuleLoaderDelegate:")), with: loader)
        }
    }

    func evaluateJSScript(_ script: Any) -> JSValue {
        return self.perform(Selector(("evaluateJSScript:")), with: script).takeRetainedValue() as! JSValue
    }
}
