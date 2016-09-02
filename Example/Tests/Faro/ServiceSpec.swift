import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {
    override func spec() {
        describe("Service") {
            context("MockService") {
                it("should return mockModel in sync"){
                    let expected = ["key" : "value"]
                    let service = MockService(mockJSON: expected)
                    let order = Order(path: "mock")
                    var isInSync = false
                    service.serve(order, result: { (result : Result <MockModel>) in
                        isInSync = true
                        switch result {
                        case .JSON(json: let json):
                            expect(json).to(beIdenticalTo(expected))
                        default:
                            XCTFail("You should succeed")
                        }
                    })

                    expect(isInSync).to(beTrue())
                }

                context("Failure") {
                    it("InvalidAuthentication when statuscode 404") {
                        let expected = ["key" : "value"]
                        let service = MockService(mockJSON: expected)

                        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 404, HTTPVersion: nil, headerFields: nil)


                        expect{try service.checkStatusCodeAndData(nil, urlResponse: response, error: nil)}.to(throwError(Error.InvalidAuthentication))
                    }
                }
            }

            context("JSONService Asynchronous", {
                it("should fail for a wierd url") {
                    let configuration = Faro.Configuration(baseURL: "wierd")
                    let service = JSONService(configuration: configuration)
                    let order = Order(path: "posts")

                    var failed = false

                    service.serve(order, result: { (result : Result <MockModel>) in
                        switch result {
                        case .Failure :
                            failed = true
                        default :
                            XCTFail("💣should fail")
                        }
                    })

                    expect(failed).toEventually(beTrue())
                }

                it("should return an empty model") {
                    let configuration = Faro.Configuration(baseURL: "http://jsonplaceholder.typicode.com")
                    let service = JSONService(configuration: configuration)
                    let order = Order(path: "posts")

                    var receivedJSON = false

                    service.serve(order, result: { (result : Result <MockModel>) in
                        switch result {
                        case .JSON(let json) :
                            if let json = json as? [[String: AnyObject]] {
                                expect(json.count).to(equal(100))
                                receivedJSON = true
                            }else {
                                XCTFail("\(json) is wrong")
                            }
                        default :
                            XCTFail("💣should return json")
                        }
                    })

                    expect(receivedJSON).toEventually(beTrue())
                }
            })
        }
    }  
}
