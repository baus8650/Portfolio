import Fluent

struct CreateProject: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("yearCompleted", .int, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("projects").delete()
    }
}
