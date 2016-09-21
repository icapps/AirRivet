import Quick
import Nimble

import Faro
@testable import Faro_Example

class CallSpec: QuickSpec {

    override func spec() {
        describe("Call .GET") {
            let expected = "path"
            let call = Call(path: expected)
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            context("setup") {
                it("should have a path") {
                    expect(call.path).to(equal(expected))
                }

                it("should default to .GET") {
                    let request = call.request(withConfiguration: configuration)!
                    expect(request.httpMethod).to(equal("GET"))
                }

                it("should configuration should make up request") {
                    let request = call.request(withConfiguration: configuration)!
                    expect(request.url!.absoluteString).to(equal("http://someURL/path"))
                }
            }

            context("Root JSON node extraction") {
                it("should return an object if JSON is single node") {

                    let node = call.rootNode(from: ["key": "value"])
                    switch node {
                    case .nodeObject(let node):
                        expect(node["key"] as! String?).to(equal("value"))
                    default:
                        XCTFail("should fetch node")
                    }
                }
            }
        }

        describe("Call .Get with RootNode") {

            let expected = "path"
            let call = Call(path: expected, rootNode: "rootNode")

            it("should extract single object from a rootNode") {
                let node = call.rootNode(from: ["rootNode": ["key": "value"]])
                switch node {
                case .nodeObject(let node):
                    expect(node["key"] as! String?).to(equal("value"))
                default:
                    XCTFail("should fetch node")
                }
            }

            it("should extract Array of objects from a rootNode") {
                let node = call.rootNode(from: ["rootNode": [["key": "value"]]])
                switch node {
                case .nodeArray(let nodes):
                    expect(nodes.count).to(equal(1))
                default:
                    XCTFail("should fetch node")
                }
            }

        }
        
        describe("Call with parameters") {
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            func allHTTPHeaderFields(type: ParameterType, parameters: [String: Any]) -> [String: String] {
                let params = Parameters(type: type, parameters: parameters )
                let call = Call(path: "path", parameters: params)
                let request = call.request(withConfiguration: configuration)
                return request!.allHTTPHeaderFields!
            }

            func componentString(type: ParameterType, parameters: [String: Any]) -> String {
                let params = Parameters(type: type, parameters: parameters )
                let call = Call(path: "path", parameters: params)
                let request = call.request(withConfiguration: configuration)
                return request!.url!.absoluteString
            }

            func body(type: ParameterType, method: HTTPMethod, parameters: [String: Any]) -> Data? {
                let params = Parameters(type: type, parameters: parameters )
                let call = Call(path: "path", method: method, parameters: params)
                let request = call.request(withConfiguration: configuration)
                return request!.httpBody
            }

            it("should insert http headers into the request") {

                let headers = allHTTPHeaderFields(type: .httpHeader, parameters: ["Accept-Language" : "en-US",
                                                                                  "Accept-Charset" : "utf-8"])
                expect(headers.keys).to(contain("Accept-Language"))
                expect(headers.values).to(contain("utf-8"))
            }
            
            it("should fail to insert http headers that arent strings into the request") {

                let headers = allHTTPHeaderFields(type: .httpHeader, parameters:  ["Accept-Language" : 12345,
                                                                                   "Accept-Charset" : Data(base64Encoded: "el wrongo")])
                expect(headers.keys).toNot(contain("Accept-Language"))
                expect(headers.keys).toNot(contain("Accept-Charset"))
            }
            
            it("should insert URL components into the request") {
                let string = componentString(type: .urlComponents, parameters: ["some query item": "aa🗿🤔aej"])
                expect(string).to(contain("some%20query%20item=aa%F0%9F%97%BF%F0%9F%A4%94aej"))
            }
            
            it("should fail to insert URL components that arent strings into the request") {
                let string = componentString(type: .urlComponents, parameters:  ["some dumb query item": Data(base64Encoded: "el wrongo")])
                expect(string).toNot(contain("some%20dumb%20query%20item"))
            }
            
            it("should add JSON into the request body into the request") {
                let data = body(type: .jsonBody, method: .PUT, parameters: ["a string": "good day i am a string",
                                                                            "a number": 123])
                let jsonDict = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]

                expect(jsonDict.keys.count).to(equal(2))
            }
            
            it("should fail to add JSON into a GET or DELETE request") {
                let data = body(type: .jsonBody, method: .GET, parameters: ["a string": "good day i am a string",
                                                              "a number": 123])
                expect(data).to(beNil())
            }
        }
    }

}
