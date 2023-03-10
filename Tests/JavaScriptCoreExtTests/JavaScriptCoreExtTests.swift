import XCTest
@testable import JavaScriptCore
@testable import JavaScriptCoreExt

let SOURCE = """
import exported from "file:///hello.js";

export const test = "test";

print("test");
print(exported);

Promise.resolve().then(() => {
    print("promise");
});

throw new Error("test error");
"""

class MyModuleLoader: NSObject, JSModuleLoaderDelegate {
    func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!) {
        RunLoop.main.perform {
            print("fetchModuleForIdentifier: \(identifier!)")
            let script = try! JSCExtScript(
                of: .module,
                withSource: identifier.toString() == "file:///hello.js" ? "print('hello'); export default 'exported';" : SOURCE,
                andSourceURL: URL(string: identifier.toString())!,
                in: context.virtualMachine
            )
            resolve.call(withArguments: [script])
        }
    }

    func willEvaluateModule(_ key: URL?) {
        print("willEvaluateModule: \(key!)")
    }

    func didEvaluateModule(_ key: URL?) {
        print("didEvaluateModule: \(key!)")
    }
}

final class JavaScriptCoreExtTests: XCTestCase {
    func testExample() throws {
        let vm = JSVirtualMachine()!
        let context = JSContext(virtualMachine: vm)!

        let loader = MyModuleLoader()
        context.moduleLoaderDelegate = loader

        context.exceptionHandler = { context, value in
            print("JSError: \(value!)")
        }

        context.setObject(
            {()->@convention(block) (JSValue)->Void in { print($0) }}(),
            forKeyedSubscript: "print" as NSString
        )
        
        let _ = context.evaluateScript("""
        import('file:///test.js').then((x) => {
            print('mod then')
            print(x.test)
            return x
        }).catch((e) => {
            print('mod catch')
            print(e.message)
        })
        """)!
        
        let out = RunLoop.main.run(mode: .default, before: .distantPast)
        print("runloop done \(out)")
    }
}
