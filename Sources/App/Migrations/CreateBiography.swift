import Fluent

struct CreateBiography: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("biography")
            .id()
            .field("bio", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("biography").delete()
    }
}
