import Fluent
import FluentPostgresDriver
import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    app.middleware.use(app.sessions.middleware)

    let databaseName: String
    let databasePort: Int
    if (app.environment == .testing) {
        databaseName = "vapor-test"
        databasePort = 5433
    } else {
        databaseName = "vapor_database"
        databasePort = 5432
    }
    
    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateApplicationType())
    app.migrations.add(CreateProject())
    app.migrations.add(CreateSkill())
    app.migrations.add(CreateProjectSkillPivot())
    app.migrations.add(CreateScreenShot())
    app.migrations.add(CreateReview())
    app.migrations.add(CreateToken())
    app.migrations.add(CreateAdminUser())
    
    app.routes.defaultMaxBodySize = "30mb"
    
    app.logger.logLevel = .debug
    
    try app.autoMigrate().wait()

    app.views.use(.leaf)

    

    // register routes
    try routes(app)
}
