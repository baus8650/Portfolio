import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    let projectsController = ProjectsController()
    try app.register(collection: projectsController)
    
    let skillsController = SkillsController()
    try app.register(collection: skillsController)
    
}
