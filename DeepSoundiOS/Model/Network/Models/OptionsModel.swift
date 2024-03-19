import Foundation

struct OptionsModel : Codable {
    
	let status : Int?
	let data : OptionsData?

	enum CodingKeys: String, CodingKey {
		case status = "status"
		case data = "data"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		status = try values.decodeIfPresent(Int.self, forKey: .status)
		data = try values.decodeIfPresent(OptionsData.self, forKey: .data)
	}

}
