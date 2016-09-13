import Quick
import Nimble

@testable import Faro

class JSONAdaptorSpec: QuickSpec {

    override func spec() {
        describe("JSONAdaptor") {

            it("should return an empty model") {
                let adaptor = JSONAdaptor()

                var receivedJSON = false

                let dataResult: Result<MockModel> = Result.data("{\"key\":100}".data(using: String.Encoding.utf8)!)
                adaptor.serialize(fromDataResult: dataResult, result: { (result: Result<MockModel>) in
                    switch result {
                    case .json(let json):
                        if let json = json as? [String: Int] {
                            expect(json["key"]).to(equal(100))
                            receivedJSON = true
                        } else {
                            XCTFail("\(json) is wrong")
                        }
                    default:
                        XCTFail("💣should return json")
                    }
                })

                expect(receivedJSON).toEventually(beTrue())
            }
        }
    }

}
