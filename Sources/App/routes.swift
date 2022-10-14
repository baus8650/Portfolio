import Fluent
import Vapor

func routes(_ app: Application) throws {
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let typesController = ApplicationTypesController()
    try app.register(collection: typesController)
    
    let projectsController = ProjectsController()
    try app.register(collection: projectsController)
    
    let skillsController = SkillsController()
    try app.register(collection: skillsController)
    
    let screenShotsController = ScreenShotsController()
    try app.register(collection: screenShotsController)
    
    let reviewssController = ReviewsController()
    try app.register(collection: reviewssController)
    
    let websiteController = WebsiteController()
    try app.register(collection: websiteController)    
}
