import AirRivet

/**
Model object that implements protocol `BaseModel` that can be fount in pod `AirRivet`.

In this example GameScore has to inherit from NSObject to be usable in Objective-C. In a pure Swift project this is not needed.
*/
public class GameScore: NSObject, UniqueAble,  Mitigatable, Parsable, EnvironmentConfigurable {

	public var score: Int?
	public var cheatMode: Bool?
	public var playerName: String?

	public var objectId: String?

	public required override init() {
		super.init()
	}

	public func toDictionary()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}

	public func parseFromDict(json: AnyObject) throws {
		if let json = json as? NSDictionary {
			if let objectId = json["objectId"] as? String {
				self.objectId = objectId
			}
			if let score = json["score"] as? Int {
				self.score = score
			}
			if let cheatMode = json["cheatMode"] as? Bool {
				self.cheatMode = cheatMode
			}

			if let playerName = json["playerName"] as? String {
				self.playerName = playerName
			}
		}
	}

	//MARK: Mitigatable
	
	public func responseMitigator() -> ResponseMitigatable {
		return DefaultMitigator()
	}

	public static func requestMitigator() -> RequestMitigatable {
		return DefaultMitigator()
	}

	//MARK: EnvironmentConfigurable
	public func contextPath() -> String {
		return "GameScore"
	}

	public func environment()-> protocol<Environment, Mockable, Transformable> {
		return Parse<GameScore>()
	}

	public static func rootKey() -> String? {
		return "results"
	}
}