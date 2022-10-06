import Fluent
import Vapor

struct ProjectsController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let projectsRoutes = routes.grouped("api", "projects")
        projectsRoutes.get(use: getAllHandler)
        projectsRoutes.post(use: createHandler)
        projectsRoutes.get(":projectID", use: getHandler)
        projectsRoutes.get(":projectID", use: updateHandler)
        projectsRoutes.delete(":projectID", use: deleteHandler)
        projectsRoutes.get("search", use: searchHandler)
        projectsRoutes.get("first", use: getFirstHandler)
        projectsRoutes.get("sorted", use: sortedHandler)
        
        projectsRoutes.post(":projectID", "skills", ":skillID", use: addSkillsHandler)
        projectsRoutes.get(":projectID", "categories", use: getSkillsHandler)
        projectsRoutes.delete(":projectID", "skills", ":skillID", use: removeSkillsHandler)
    }

    func getAllHandler(_ req: Request) -> EventLoopFuture<[Project]> {
        Project.query(on: req.db).all()
    }

    func createHandler(_ req: Request) throws -> EventLoopFuture<Project> {
        let project = try req.content.decode(Project.self)
        return project.save(on: req.db).map { project }
    }

    func getHandler(_ req: Request) -> EventLoopFuture<Project> {
        Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func updateHandler(_ req: Request) throws -> EventLoopFuture<Project> {
        let updatedProject = try req.content.decode(Project.self)
        return Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { project in
                project.name = updatedProject.name
                return project.save(on: req.db).map { project }
            }
    }

    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { project in
                project.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    func searchHandler(_ req: Request) throws -> EventLoopFuture<[Project]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }

        return Project.query(on: req.db).filter(\.$name == searchTerm).all()
    }

    func getFirstHandler(_ req: Request) -> EventLoopFuture<Project> {
        return Project.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    func sortedHandler(_ req: Request) -> EventLoopFuture<[Project]> {
        return Project.query(on: req.db)
            .sort(\.$name, .ascending).all()
    }
    
    // MARK: - Skills Handlers
    
    func addSkillsHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let projectQuery = Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let skillQuery = Skill.find(req.parameters.get("skillID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return projectQuery.and(skillQuery)
            .flatMap { project, skill in
                project
                    .$skills
                    .attach(skill, on: req.db)
                    .transform(to: .created)
            }
    }
    
    func getSkillsHandler(_ req: Request) -> EventLoopFuture<[Skill]> {
        Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { project in
                project.$skills.query(on: req.db).all()
            }
    }
    
    func removeSkillsHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        let projectQuery = Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let skillQuery = Skill.find(req.parameters.get("skillID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return projectQuery.and(skillQuery)
            .flatMap { project, skill in
                project
                    .$skills
                    .detach(skill, on: req.db)
                    .transform(to: .noContent)
            }
    }
}
