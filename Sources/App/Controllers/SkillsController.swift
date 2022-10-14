import Vapor

struct SkillsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let skillsRoute = routes.grouped("api", "skills")
        skillsRoute.post(use: createHandler)
        skillsRoute.get(use: getAllHandler)
        skillsRoute.get(":skillID", use: getHandler)
        skillsRoute.put(":skillID", use: updateHandler)
        skillsRoute.delete(":skillID", use: deleteHandler)
        
        skillsRoute.get(":skillID", "projects", use: getProjectsHandler)
    }
    
    func createHandler(_ req: Request)
    throws -> EventLoopFuture<Skill> {
        let skill = try req.content.decode(Skill.self)
        return skill.save(on: req.db).map { skill }
    }
    
    func getAllHandler(_ req: Request)
    -> EventLoopFuture<[Skill]> {
        Skill.query(on: req.db).all()
    }
    
    func getHandler(_ req: Request)
    -> EventLoopFuture<Skill> {
        Skill.find(req.parameters.get("skillID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func updateHandler(_ req: Request) throws -> EventLoopFuture<Skill> {
        let updatedSkill = try req.content.decode(Skill.self)
        return Skill.find(req.parameters.get("skillID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { skill in
                skill.name = updatedSkill.name
                return skill.save(on: req.db).map { skill }
            }
    }
    
    func deleteHandler(_ req: Request) -> EventLoopFuture<HTTPStatus> {
        Skill.find(req.parameters.get("skillID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { skill in
                skill.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
    
    // MARK: - Projects Handlers
    
    func getProjectsHandler(_ req: Request) -> EventLoopFuture<[Project]> {
        Skill.find(req.parameters.get("skillID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { skill in
                skill.$projects.get(on: req.db)
            }
    }
}
