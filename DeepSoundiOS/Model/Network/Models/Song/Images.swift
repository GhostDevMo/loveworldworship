
import Foundation

struct Images : Codable {
	let org_image : String?
	let image : String?

	enum CodingKeys: String, CodingKey {
		case org_image = "org_image"
		case image = "image"
	}
}
