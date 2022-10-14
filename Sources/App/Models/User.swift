import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "biography")
    var biography: String
    
    @Field(key: "isEmployed")
    var isEmployed: Bool
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "headshot")
    var headshot: String
    
    @Field(key: "password")
    var password: String
    
    init() {}
    
    init(id: UUID? = nil, name: String, isEmployed: Bool, username: String, biography: String, headshot: String, password: String) {
        self.name = name
        self.isEmployed = isEmployed
        self.biography = biography
        self.headshot = headshot
        self.username = username
        self.password = password
    }
    
    final class Public: Content {
        var id: UUID?
        var name: String
        var username: String
        var biography: String
        var headshot: String
        var isEmployed: Bool
        
        init(id: UUID?, name: String, username: String, biography: String, headshot: String, isEmployed: Bool) {
            self.id = id
            self.name = name
            self.username = username
            self.biography = biography
            self.headshot = headshot
            self.isEmployed = isEmployed
        }
    }
}


extension User {
    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username, biography: biography, headshot: headshot, isEmployed: isEmployed)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic() -> EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}

extension Collection where Element: User {
    func convertToPublic() -> [User.Public] {
        return self.map { $0.convertToPublic() }
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic() -> EventLoopFuture<[User.Public]> {
        return self.map { $0.convertToPublic() }
    }
}

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$username
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}

extension User: ModelSessionAuthenticatable {}

extension User: ModelCredentialsAuthenticatable {}
