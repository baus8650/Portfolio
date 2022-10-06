import Fluent

struct CreateSkill: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("skills")
            .id()
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("skills").delete()
    }
}
