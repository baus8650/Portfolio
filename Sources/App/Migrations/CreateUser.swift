import Fluent

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users")
        
            .id()
            .field("name", .string, .required)
            .field("username", .string, .required)
            .field("biography", .string, .required)
            .field("isEmployed", .bool, .required)
            .field("headshot", .string, .required)
            .field("password", .string, .required)
            .unique(on: "username")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("users").delete()
    }
}
