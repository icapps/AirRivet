import Faro

class MockModel: Mappable {
    var value: String

    required init(json: Any) {
        if let json = json as? [String: String] {
            value = json["key"]!
        }else {
            value = ""
        }
    }

}
