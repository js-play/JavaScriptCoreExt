import XCTest
import JavaScriptCore
@testable import JavaScriptCoreExt

let SOURCE = """
import exported from "file:///hello.js";

export const test = "test";

sleep(1000).then(() => {
    print("sleep then");
});

print("test");
print(exported);

Promise.resolve().then(() => {
    print("promise");
});

throw new Error("test error");
"""

@objc class MyModuleLoader: NSObject, JSModuleLoaderDelegate {
    @objc func context(_ context: JSContext!, fetchModuleForIdentifier identifier: JSValue!, withResolveHandler resolve: JSValue!, andRejectHandler reject: JSValue!) {
        RunLoop.main.perform {
            print("fetchModuleForIdentifier: \(identifier!)")
            let script = try! JSCExtScript(
                ofType: .module,
                withSource: identifier.toString() == "file:///hello.js" ? "print('hello'); export default 'exported';" : SOURCE,
                andSourceURL: URL(string: identifier.toString())!,
                in: context.virtualMachine
            )
            resolve.call(withArguments: [script.inner])
        }
    }

    @objc func willEvaluateModule(_ key: URL?) {
        print("willEvaluateModule: \(key!)")
    }

    @objc func didEvaluateModule(_ key: URL?) {
        print("didEvaluateModule: \(key!)")
    }

    @objc static func test() {
        print("debug")
    }
}

final class JavaScriptCoreExtTests: XCTestCase {
    func testExample() throws {
        let vm = JSVirtualMachine()!
        let context = JSContext(virtualMachine: vm)!
        let loader = MyModuleLoader()
        
        context.setModuleLoaderDelegate(loader)

        context.exceptionHandler = { context, value in
            print("JSError: \(value!)")
        }

        context.setObject(
            {()->@convention(block) (JSValue)->Void in { print($0) }}(),
            forKeyedSubscript: "print" as NSString
        )

        context.setObject(
            {()->@convention(block) (JSValue)->JSValue in { a in
                return JSValue(
                    newPromiseIn: JSContext.current()!,
                    fromExecutor: { resolve, reject in
                        let ms = a.toInt32()
                        print("sleep \(ms)ms")
                        RunLoop.main.perform(
                            inModes: [.default],
                            block: {
                                print("sleep begin")
                                Thread.sleep(forTimeInterval: TimeInterval(ms) / 1000)
                                print("sleep done")
                            }
                        )
                    }
                )
            }}(),
            forKeyedSubscript: "sleep" as NSString
        )
        
        let mod = context.evaluateScript("""
        import('file:///test.js').then((x) => {
            print('mod then')
            print(x.test) // PRINT IN JS ye its for testing
            return x
        }).catch((e) => {
            print('mod catch')
            print(e.message)
        })
        """)!
        
        mod.invokeMethod("then", withArguments: [
            MyModuleLoader.test,
            MyModuleLoader.test
        ])
        
        let out = RunLoop.main.run(mode: .default, before: .distantPast)

        print("runloop done \(out)")
    }
}
