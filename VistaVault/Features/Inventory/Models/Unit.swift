import Foundation

struct Unit: Identifiable, Codable {
    var id: String?
    var name: String
    var description: String
    var created: Date?

    init(id: String? = nil, name: String, description: String = "", created: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.created = created
    }
}
