import Foundation

public enum FaroDeserializableError: Error {
	case wrongJSON(Any?)
	case valueMissing(rhs: Any?)
	case rawRepresentableFail(rhs: Any?)
	case invalidDate(String)
	case linkNotUniqueInJSON([[String: Any]], linkValue: String)
}

// MARK: - Deserializable objects

// MARK: - Always instantiates new object

/// The operator we define assings a value. Therefore its Precendencegroup is AssignmentPrecedence.
/// Used for optional properties
infix operator <->: AssignmentPrecedence


public func <-> <P>(lhs: inout P?, rhs: Any?) where P: Deserializable {
    guard let dict = rhs as? [String: Any] else {
        lhs = nil
        return
    }
    lhs = P(from: dict)
}

public func <-> <P>(lhs: inout [P]?, rhs: Any?) where P: Deserializable {
    guard let rawObjects = rhs as? [[String: Any]] else {
        lhs = nil
        return
    }
    lhs = rawObjects.flatMap { P(from: $0) }
}

// MARK: - Instantiates or Updates

public func <-> <P>(lhs: inout P?, rhs: Any?) throws where P: Deserializable & Updatable {
	guard let dict = rhs as? [String: Any] else {
		lhs = nil
		return
	}
	if let lhs = lhs {
		try lhs.update(from: dict)
	} else {
		lhs = P(from: dict)
	}
}

public func <-> <P>(lhs: inout [P]?, rhs: Any?) throws where P: Deserializable & Updatable & Linkable, P.ValueType: Equatable {
	guard let rawObjects = rhs as? [[String: Any]] else {
		lhs = nil
		return
	}
	if var lhs = lhs, !lhs.isEmpty {
		try lhs.enumerated().forEach {
			let element = $0.element
			let dict = rawObjects.filter {($0[element.link.key] as? P.ValueType)  == element.link.value}
			if !dict.isEmpty {
				try element.update(from: dict)
			} else {
				lhs.remove(at: $0.offset)
			}
		}
	} else {
		lhs = rawObjects.flatMap { P(from: $0) }
	}
}

// MARK: - Required

public func <-> <P>(lhs: inout P, rhs: Any?) throws where P: Deserializable & Updatable {
	guard let dict = rhs as? [String: Any] else {
		throw FaroDeserializableError.wrongJSON(rhs)
	}
	try lhs.update(from: dict)
}

// MARK: - Array relations

/// Removes `Linkable.link.key` elements not found in rhs
/// ValueType of `Linkable.link.Value` is `Int`
public func <-> <P>(lhs: inout [P], rhs: Any?) throws where P: Deserializable & Updatable & Linkable & Hashable, P.ValueType: Equatable {
	guard var nodesToProcess = rhs as? [[String: Any]] else {
		throw FaroDeserializableError.wrongJSON(rhs)
	}
	if !lhs.isEmpty {
		var elementsToRemove = Set<P>()
		try lhs.enumerated().forEach {
			let element = $0.element

			let filterFunction: ([String: Any]) -> Bool = {($0[element.link.key] as? P.ValueType)  == element.link.value}
			let dict = nodesToProcess.filter(filterFunction)

			guard !dict.isEmpty, let index = nodesToProcess.index(where: filterFunction) else {
				elementsToRemove.insert($0.element)
				return
			}
			guard dict.count == 1, let elementJSON = dict.first else {
				throw FaroDeserializableError.linkNotUniqueInJSON(nodesToProcess, linkValue: "\(element.link.value)")
			}

			try element.update(from: elementJSON)
			// remove all nodes we processed
			nodesToProcess.remove(at: index)
		}

		lhs = lhs.filter {!elementsToRemove.contains($0)}
		// If we still have nodes to process. Add them.
		nodesToProcess.forEach {
			if let model = P(from: $0) {
				lhs.append(model)
			}
		}

	} else {
		lhs = nodesToProcess.flatMap { P(from: $0) }
	}

}

// MARK: - Set Relation

/// Removes `Linkable.link.key` elements not found in rhs
/// ValueType of `Linkable.link.Value` is `Int`
public func <-> <P>(lhs: inout Set<P>, rhs: Any?) throws where P: Deserializable & Updatable & Linkable, P.ValueType: Equatable {
	guard var nodesToProcess = rhs as? [[String: Any]] else {
		throw FaroDeserializableError.wrongJSON(rhs)
	}
	if !lhs.isEmpty {
		try lhs.enumerated().forEach {
			let element = $0.element

			let filterFunction: ([String: Any]) -> Bool = {($0[element.link.key] as? P.ValueType)  == element.link.value}
			let dict = nodesToProcess.filter(filterFunction)

			guard !dict.isEmpty, let index = nodesToProcess.index(where: filterFunction) else {
				lhs.remove($0.element)
				return
			}
			guard dict.count == 1 else {
				throw FaroDeserializableError.linkNotUniqueInJSON(nodesToProcess, linkValue: "\(element.link.value)")
			}
			
			try element.update(from: dict.first)
			// remove all nodes we processed
			nodesToProcess.remove(at: index)
		}

		// If we still have nodes to process. Add them.
		nodesToProcess.forEach {
			if let model = P(from: $0) {
				lhs.insert(model)
			}
		}

	} else {
		lhs = Set<P>(nodesToProcess.flatMap { P(from: $0) })
	}
	
}

// MARK: - Primitive Types

/// `Any?` is taken and set to the left hand side.
public func <-> (lhs: inout Int?, rhs: Any?) {
    lhs = rhs as? Int
}

public func <-> (lhs: inout Double?, rhs: Any?) {
    lhs = rhs as? Double
}

public func <-> (lhs: inout Bool?, rhs: Any?) {
    lhs = rhs as? Bool
}

public func <-> (lhs: inout String?, rhs: Any?) {
    lhs = rhs as? String
}

public func <-> (lhs: inout Date?, rhs: TimeInterval?) {
    guard let timeInterval = rhs else {
        return
    }

    lhs = Date(timeIntervalSince1970: timeInterval)
}

public func <-> (lhs: inout Date?, rhs: (Any?, String)) {
    guard let date = rhs.0 as? String else {
        return
    }

    DateParser.shared.dateFormat = rhs.1
    lhs = DateParser.shared.dateFormatter.date(from: date)
}

// MARK: - Required

public func <-> (lhs: inout Int, rhs: Any?) throws {
	guard let value = rhs as? Int else {
		throw FaroDeserializableError.valueMissing(rhs: rhs)
	}
	lhs = value
}

public func <-> (lhs: inout Double, rhs: Any?) throws {
	guard let value = rhs as? Double else {
		throw FaroDeserializableError.valueMissing(rhs: rhs)
	}
	lhs = value
}

public func <-> (lhs: inout Bool, rhs: Any?) throws {
	guard let value = rhs as? Bool else {
		throw FaroDeserializableError.valueMissing(rhs: rhs)
	}
	lhs = value
}

public func <-> (lhs: inout String, rhs: Any?) throws {
	guard let value = rhs as? String else {
		throw FaroDeserializableError.valueMissing(rhs: rhs)
	}
	lhs = value
}

public func <-> (lhs: inout Date, rhs: TimeInterval?) throws {
	guard let timeInterval = rhs else {
		throw FaroDeserializableError.valueMissing(rhs: rhs)
	}

	lhs = Date(timeIntervalSince1970: timeInterval)
}

public func <-> (lhs: inout Date, rhs: (Any?, String)) throws {
	guard let date = rhs.0 as? String else {
		throw FaroDeserializableError.valueMissing(rhs: rhs)
	}

	DateParser.shared.dateFormat = rhs.1
	guard let parsedDate = DateParser.shared.dateFormatter.date(from: date) else {
		throw FaroDeserializableError.invalidDate(date)
	}

	lhs = parsedDate
}

// MARK: - RawRepresentable Types

// MARK: - String

// MARK: - Required

public func <-> <T> (lhs: inout T, rhs: Any?) throws where T: RawRepresentable, T.RawValue == String {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		throw FaroDeserializableError.rawRepresentableFail(rhs: rhs)
	}
	lhs = value
}

// MARK: - Optional

public func <-> <T> (lhs: inout T?, rhs: Any?) where T: RawRepresentable, T.RawValue == String {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		lhs = nil
		return
	}
	lhs = value
}

// MARK: - Int

// MARK: - Required

public func <-> <T> (lhs: inout T, rhs: Any?) throws where T: RawRepresentable, T.RawValue == Int {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		throw FaroDeserializableError.rawRepresentableFail(rhs: rhs)
	}
	lhs = value
}

// MARK: - Optional

public func <-> <T> (lhs: inout T?, rhs: Any?) where T: RawRepresentable, T.RawValue == Int {
	guard let stringValue = rhs as? T.RawValue, let value = T(rawValue: stringValue) else {
		lhs = nil
		return
	}
	lhs = value
}


