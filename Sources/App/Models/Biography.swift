import Vapor
import Fluent

final class Biography: Model {
    static let schema = "biography"
    
    @ID
    var id: UUID?
    
    @Field(key: "bio")
    var bio: String
    
    init() {}
    
    init(id: UUID? = nil, bio: String) {
        self.id = id
        self.bio = bio
    }
}
