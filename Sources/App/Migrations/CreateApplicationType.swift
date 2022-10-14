import Fluent

struct CreateApplicationType: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("applicationTypes")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("applicationTypes").delete()
    }
}
