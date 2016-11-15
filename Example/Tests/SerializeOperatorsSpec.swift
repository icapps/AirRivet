
import Quick
import Nimble

import Faro
@testable import Faro_Example

class SerializableObject: Serializable {
    var uuid: String?
    var amount: Int?
    var price: Double?
    var tapped: Bool?
    var date: Date?
    var json: [String : Any] {
        get {
            var json = [String: Any]()
            json["uuid"] <-> uuid
            json["amount"] <-> amount
            json["price"] <-> price
            json["tapped"] <-> tapped
            json["date"] <-> date
            return json
        }
    }

}

class SerializeOpereratorsSpec: QuickSpec {

    override func spec() {
        describe("Date serialization") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            it("to a timeinterval since 1970 by default") {
                let date = formatter.date(from: "1994-08-20")!

                var serializedDate: Any?
                serializedDate <-> date

                expect(serializedDate as? Double) == date.timeIntervalSince1970
            }

            it("should serialize to a requested format") {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let date = formatter.date(from: "1994-08-20")

                var serializedDate: Any?
                serializedDate <-> (date, "yyyy-MM-dd")


                expect(serializedDate as? String) == "1994-08-20"

            }
        }

        describe("SerializeOpereratorsSpec") {

            it("should serialize to JSON object") {
                var serializedDictionary: Any?
                let o1 = SerializableObject()
                o1.uuid = "ID1"
                o1.amount = 20

                serializedDictionary <-> o1

                let dict = serializedDictionary as! [String: Any]

                expect(dict["uuid"] as? String) == o1.uuid
                expect(dict["amount"] as? Int) == o1.amount
            }

            it("should serialize to JSON array") {
                var serializedDictionary: Any?
                let o1 = SerializableObject()
                o1.uuid = "ID1"
                let o2 = SerializableObject()
                o2.uuid = "ID2"

                serializedDictionary <-> [o1, o2]

                let dictArray = serializedDictionary as! [[String: Any]]

                expect(dictArray.count) == 2
                expect(dictArray.first!["uuid"] as? String) == o1.uuid
                expect(dictArray.last!["uuid"] as? String) == o2.uuid

            }

            it("should serialize strings") {
                var serializedType: Any?
                let o1 = SerializableObject()
                o1.uuid = "id1"

                serializedType <-> o1.uuid

                let serializedString = serializedType as! String

                expect(serializedString) == o1.uuid
            }

            it("should serialize integers") {
                var serializedType: Any?
                let o1 = SerializableObject()
                o1.amount = 20

                serializedType <-> o1.amount

                let serializedInt = serializedType as! Int

                expect(serializedInt) == o1.amount
            }

            it("should serialize booleans") {
                var serializedType: Any?
                let o1 = SerializableObject()
                o1.tapped = true

                serializedType <-> o1.tapped

                let serializedBool = serializedType as! Bool

                expect(serializedBool) == o1.tapped
            }

            it("should serialize doubles") {
                var serializedType: Any?
                let o1 = SerializableObject()
                o1.price = 5.0

                serializedType <-> o1.price

                let serializedDouble = serializedType as! Double

                expect(serializedDouble) == o1.price
            }
        }
    }

}
