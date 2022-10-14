import Leaf
import Fluent
import Vapor

struct WebsiteController: RouteCollection {
    let appIconFolder = "Public/Images/AppIcons/"
    let screenShotFolder = "Public/Images/ScreenShots/"
    let headShotFolder = "Public/Images/Headshots/"
    
    func boot(routes: RoutesBuilder) throws {
        let authSessionsRoutes = routes.grouped(User.sessionAuthenticator())
        
        routes.get(use: indexHandler)
        routes.get("projects", ":projectID", use: projectHandler)
        
        authSessionsRoutes.get("login", use: loginHandler)
        let credentialsAuthRoutes = authSessionsRoutes.grouped(User.credentialsAuthenticator())
        credentialsAuthRoutes.post("login", use: loginPostHandler)
        authSessionsRoutes.post("logout", use: logoutHandler)
        
        let protectedRoutes = authSessionsRoutes.grouped(User.redirectMiddleware(path: "/login"))
        protectedRoutes.get("admin", use: adminHandler)
        protectedRoutes.get("admin", ":projectID", use: adminProjectHandler)
        protectedRoutes.get("admin", ":projectID", "edit", use: adminEditProjectHandler)
        protectedRoutes.post("admin", ":projectID", "edit", use: editProjectPostHandler)
        protectedRoutes.get("projects", "create", use: adminCreateProjectHandler)
        protectedRoutes.post("projects", "create", use: createProjectPostHandler)
        
        protectedRoutes.get("types", "create", use: adminCreateTypeHandler)
        protectedRoutes.post("types", "create", use: createTypePostHandler)
        
        protectedRoutes.get("screenshots", "create", use: admincCreateGeneralScreenShotHandler)
        protectedRoutes.post("screenshots", "create", use: createGeneralScreenShotPostHandler)
        protectedRoutes.get("screenshots", ":projectID", "create", use: adminCreateScreenShotHandler)
        protectedRoutes.post("screenshots", ":projectID", "create", use: createScreenShotPostHandler)
        
        
        protectedRoutes.get("reviews", "create", use: admincCreateGeneralReviewHandler)
        protectedRoutes.post("reviews", "create", use: createGeneralReviewPostHandler)
        
        protectedRoutes.get("screenshots", ":projectID", "reviews", ":projectID", "create", use: adminCreateReviewHandler)
        protectedRoutes.post("screenshots", ":projectID", "reviews", ":projectID", "create", use: createReviewPostHandler)
        
        protectedRoutes.get("admin", "edit", ":userID", use: editUserHandler)
        protectedRoutes.post("admin", "edit", ":userID", use: editUserPostHandler)
        
    }
    
    func indexHandler(_ req: Request) -> EventLoopFuture<View> {
        User.query(on: req.db).all().flatMap { users in
            Project.query(on: req.db).with(\.$applicationType).all().flatMap { projects in
                let newProjects = projects.map { project in
                    ProjectWithType(id: project.id, name: project.name, yearCompleted: project.yearCompleted, shortDescription: project.shortDescription, appIcon: project.appIcon, type: project.applicationType)
                }
                let context = IndexContext(title: "Tim Bausch Dev", projects: newProjects, users: users)
                return req.view.render("index", context)
            }
        }
//        Project.query(on: req.db).all().flatMap { projects in
//            User.query(on: req.db).all().flatMap { users in
//                let context = IndexContext(title: "Tim Bausch Dev", projects: projects, users: users)
//                return req.view.render("index", context)
//            }
//        }
//        Project.query(on: req.db).with(\.$applicationType).all().flatMap { projects in
//            let projectsWithType = projects.map { project in
//                ProjectWithType(id: project.id, name: project.name, yearCompleted: project.yearCompleted, shortDescription: project.shortDescription, longDescription: project.longDescription, appLink: project.appLink, repoLink: project.repoLink, appIcon: project.appIcon, skills: project.skills, applicationTypeID: project.type)
//            }
//            User.query(on: req.db).all().flatMap { users in
//                projects.map
//                let context = IndexContext(title: "Tim Bausch Dev", projects: projectsWithType, user: users)
//                return req.view.render("index", context)
//            }
//        }
    }
    
    func projectHandler(_ req: Request) -> EventLoopFuture<View> {
        
        Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { project in
                project.$skills.get(on: req.db).flatMap { skills in
                    project.$screenShots.get(on: req.db).flatMap { screenshots in
                        project.$reviews.get(on: req.db).flatMap { reviews in
                            project.$applicationType.get(on: req.db).flatMap { type in
                                let context = ProjectContext(name: project.name, project: project, skills: skills, screenshots: screenshots, reviews: reviews, type: type)
                                return req.view.render("project", context)
                            }
                        }
                    }
                }
            }
    }
    
    func adminHandler(_ req: Request) -> EventLoopFuture<View> {
        Project.query(on: req.db).all().flatMap { projects in
            ScreenShot.query(on: req.db).all().flatMap { screenShots in
                Review.query(on: req.db).all().flatMap { reviews in
                    User.query(on: req.db).all().flatMap { users in
                        let context = AdminContext(users: users, projects: projects, screenshots: screenShots, reviews: reviews)
                        return req.view.render("admin", context)
                    }
                }
            }
        }
    }
    
    func adminProjectHandler(_ req: Request) -> EventLoopFuture<View> {
        Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { project in
                project.$skills.get(on: req.db).flatMap { skills in
                    let context = AdminProjectDetailContext(project: project, skills: skills)
                    return req.view.render("adminProjectDetail", context)
                }
            }
    }
    
    func adminCreateProjectHandler(_ req: Request) -> EventLoopFuture<View> {
        ApplicationType.query(on: req.db).all().flatMap { types in
            let context = CreateProjectContext(types: types)
            return req.view.render("createProject", context)
        }
    }
    
    func createProjectPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateProjectFormData.self)
        
        let appIconName = "\(UUID()).jpg"
        let path =
        req.application.directory.workingDirectory +
        appIconFolder + appIconName
        
        return req.fileio
            .writeFile(.init(data: data.appIcon!), at: path)
            .flatMap {
                let project = Project(name: data.name, yearCompleted: data.yearCompleted, shortDescription: data.shortDescription, longDescription: data.longDescription, appLink: data.appLink, repoLink: data.repoLink, appIcon: appIconName, applicationType: data.applicationTypeID)
                
                return project.save(on: req.db).flatMap {
                    var skillSaves: [EventLoopFuture<Void>] = []
                    for skill in data.skills ?? [] {
                        skillSaves.append(Skill.addSkill(skill, to: project, on: req))
                    }
                    
                    let redirect = req.redirect(to: "/screenshots/\(project.id!)/create")
                    return skillSaves.flatten(on: req.eventLoop)
                        .transform(to: redirect)
                }
            }
    }
    
    func adminEditProjectHandler(_ req: Request) -> EventLoopFuture<View> {
        let projectFuture = Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        let screenShotQuery = ScreenShot.query(on: req.db).all()
        let reviewQuery = Review.query(on: req.db).all()
        let typeQuery = ApplicationType.query(on: req.db).all()
        
        return projectFuture.and(screenShotQuery).flatMap { project, screenShots in
            reviewQuery.flatMap { reviews in
                typeQuery.flatMap { types in
                    project.$skills.get(on: req.db).flatMap { skills in
                        let context = EditProjectContext(project: project, types: types, screenShots: screenShots, reviews: reviews, skills: skills)
                        return req.view.render("createProject", context)
                    }
                }
            }
        }
    }
    
    func editProjectPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let updateData = try req.content.decode(CreateProjectFormData.self)
        return Project.find(req.parameters.get("projectID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { project in
                project.name = updateData.name
                project.yearCompleted = updateData.yearCompleted
                project.shortDescription = updateData.shortDescription
                project.longDescription = updateData.longDescription
                project.appLink = updateData.appLink
//                project.appIcon = updateData.appIcon
                project.$applicationType.id = updateData.applicationTypeID
                let redirect = req.redirect(to: "/admin")
                return project.save(on: req.db).flatMap {
                    project.$skills.get(on: req.db)
                }.flatMap { existingSkills in
                    let existingStringArray = existingSkills.map {
                        $0.name
                    }
                    
                    let existingSet = Set<String>(existingStringArray)
                    let newSet = Set<String>(updateData.skills ?? [])
                    
                    let skillsToAdd = newSet.subtracting(existingSet)
                    let skillsToRemove = existingSet.subtracting(newSet)
                    var skillResults: [EventLoopFuture<Void>] =  []
                    
                    for newSkill in skillsToAdd {
                        skillResults.append(Skill.addSkill(newSkill, to: project, on: req))
                    }
                    for skillNameToRemove in skillsToRemove {
                        let skillToRemove = existingSkills.first {
                            $0.name == skillNameToRemove
                        }
                        if let skill = skillToRemove {
                            skillResults.append(project.$skills.detach(skill, on: req.db))
                        }
                    }
                    let redirect = req.redirect(to: "/admin")
                    return skillResults.flatten(on: req.eventLoop).transform(to: redirect)
                }
            }
    }
    
    func adminCreateTypeHandler(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("createType")
    }
    
    func createTypePostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(CreateTypeFormData.self)
        let type = ApplicationType(name: data.name)
        
        return type.save(on: req.db).flatMapThrowing {
            return req.redirect(to: "/projects/create")
        }
    }
    
    func adminCreateScreenShotHandler(_ req: Request) -> EventLoopFuture<View> {
        let projectID = req.parameters.get("projectID")
        let context = CreateScreenShotData(projectID: projectID!)
        return req.view.render("createScreenShot", context)
    }
    
    func admincCreateGeneralScreenShotHandler(_ req: Request) -> EventLoopFuture<View> {
        Project.query(on: req.db).all().flatMap { projects in
            let context = GeneralAddScreenShotData(projects: projects)
            return req.view.render("createGeneralScreenshot", context)
        }
    }
    
    func createScreenShotPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let projectID = req.parameters.get("projectID")
        let data = try req.content.decode(CreateScreenShotFormData.self)
        
        let screenShotName = "\(UUID()).jpg"
        let path =
        req.application.directory.workingDirectory +
        screenShotFolder + screenShotName
        
        return req.fileio
            .writeFile(.init(data: data.image), at: path)
            .flatMap {
                let screenShot = ScreenShot(description: data.description, image: screenShotName, project: UUID(uuidString: projectID!)!)
                
                return screenShot.save(on: req.db).flatMapThrowing {
                    return req.redirect(to: "/screenshots/\(projectID!)/create")
                }
                
            }
    }
    
    func createGeneralScreenShotPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let data = try req.content.decode(GeneralCreateScreenShotFormData.self)
        
        let screenShotName = "\(UUID()).jpg"
        let path =
        req.application.directory.workingDirectory +
        screenShotFolder + screenShotName
        
        return req.fileio
            .writeFile(.init(data: data.image), at: path)
            .flatMap {
                let screenShot = ScreenShot(description: data.description, image: screenShotName, project: data.project)
                
                return screenShot.save(on: req.db).flatMapThrowing {
                    return req.redirect(to: "/admin")
                }
                
            }
    }
    
    func admincCreateGeneralReviewHandler(_ req: Request) -> EventLoopFuture<View> {
        Project.query(on: req.db).all().flatMap { projects in
            let context = GeneralAddReviewData(projects: projects)
            return req.view.render("createGeneralReview", context)
        }
    }
    
    func createGeneralReviewPostHandler(_ req: Request) throws
    -> EventLoopFuture<Response> {
        let data = try req.content.decode(GeneralCreateReviewFormData.self)
        let review = Review(ratingValue: data.reviewValue, reviewTitle: data.reviewTitle, ratingComment: data.reviewDescription, project: data.project)
        return review.save(on: req.db).flatMapThrowing {
            return req.redirect(to: "/admin")
        }
    }
    
    
    func adminCreateReviewHandler(_ req: Request) -> EventLoopFuture<View> {
        let projectID = req.parameters.get("projectID")
        let context = CreateReviewData(projectID: projectID!)
        return req.view.render("createReview", context)
    }
    
    func createReviewPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let projectID = req.parameters.get("projectID")!
        let data = try req.content.decode(CreateReviewFormData.self)
        let review = Review(ratingValue: data.reviewValue, reviewTitle: data.reviewTitle, ratingComment: data.reviewDescription, project: UUID(uuidString: projectID)!)
        return review.save(on: req.db).flatMapThrowing {
            return req.redirect(to: "/screenshots/\(projectID)/reviews/\(projectID)/create")
        }
    }
    
    func editUserHandler(_ req: Request) -> EventLoopFuture<View> {
        let userFuture = User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        
        return userFuture.flatMap { user in
            let context = EditUserContext(user: user)
            return req.view.render("editUser", context)
        }
        
        
    }
    
    func editUserPostHandler(_ req: Request) throws -> EventLoopFuture<Response> {
        let updateData = try req.content.decode(UserFormData.self)
        
        let headShotName = "\(UUID()).jpg"
        let path =
        req.application.directory.workingDirectory +
        headShotFolder + headShotName
        
        return req.fileio
            .writeFile(.init(data: updateData.headshot), at: path)
            .flatMap {
                return User.find(req.parameters.get("userID"), on: req.db)
                    .unwrap(or: Abort(.notFound)).flatMap { user in
                        user.name = updateData.name
                        user.biography = updateData.biography
                        user.username = updateData.username
                        user.headshot = headShotName
                        let redirect = req.redirect(to: "/admin")
                        return user.save(on: req.db).transform(to: redirect)
                }
                
            }
//        return User.find(req.parameters.get("userID"), on: req.db)
//            .unwrap(or: Abort(.notFound)).flatMap { user in
//                user.name = updateData.name
//                user.biography = updateData.biography
//                let redirect = req.redirect(to: "/admin")
//                return user.save(on: req.db).transform(to: redirect)
//            }
    }
    
    // MARK: - LOG IN
    
    func loginHandler(_ req: Request) -> EventLoopFuture<View> {
        let context: LoginContext
        
        if let error = req.query[Bool.self, at: "error"], error {
            context = LoginContext(loginError: true)
        } else {
            context = LoginContext()
        }
        
        return req.view.render("login", context)
    }
    
    func loginPostHandler(
        _ req: Request
    ) -> EventLoopFuture<Response> {
        if req.auth.has(User.self) {
            return req.eventLoop.future(req.redirect(to: "/admin"))
        } else {
            let context = LoginContext(loginError: true)
            return req
                .view
                .render("login", context)
                .encodeResponse(for: req)
        }
    }

    func logoutHandler(_ req: Request) -> Response {
        req.auth.logout(User.self)
        return req.redirect(to: "/")
    }
    
}

struct IndexContext: Encodable {
    let title: String
    let projects: [ProjectWithType]
    let users: [User]
}

struct ProjectWithType: Content {
    let id: UUID?
    let name: String
    let yearCompleted: Int
    let shortDescription: String
    let appIcon: String?
    let type: ApplicationType
}

struct ProjectContext: Encodable {
    let name: String
    let project: Project
    let skills: [Skill]
    let screenshots: [ScreenShot]
    let reviews: [Review]
    let type: ApplicationType
}

struct AdminContext: Encodable {
    let title = "Admin Portal"
    let users: [User]
    let projects: [Project]
    let screenshots: [ScreenShot]
    let reviews: [Review]
}


struct AdminProjectDetailContext: Encodable {
    let project: Project
    let skills: [Skill]
}

struct CreateProjectContext: Encodable {
    let title = "Create A Project"
    let types: [ApplicationType]
}

struct CreateProjectFormData: Content {
    let name: String
    let yearCompleted: Int
    let shortDescription: String
    let longDescription: String
    let appLink: String
    let repoLink: String?
    let appIcon: Data?
    let skills: [String]?
    let applicationTypeID: UUID
}

struct CreateTypeContext: Encodable {
    let title = "Create A Type"
}

struct CreateTypeFormData: Content {
    let name: String
}

struct CreateScreenShotData: Encodable {
    let title = "Add Screenshots to Project"
    let projectID: String
}

struct CreateReviewData: Encodable {
    let title = "Add Reviews to Project"
    let projectID: String
}

struct CreateScreenShotFormData: Content {
    let image: Data
    let description: String
}

struct CreateReviewFormData: Content {
    let reviewValue: Int
    let reviewTitle: String
    let reviewDescription: String
}

struct GeneralAddScreenShotData: Encodable {
    let title = "Add New Screenshot"
    let projects: [Project]
}

struct GeneralCreateScreenShotFormData: Content {
    let image: Data
    let description: String
    let project: UUID
}

struct GeneralAddReviewData: Encodable {
    let title = "Add New Review"
    let projects: [Project]
}

struct GeneralCreateReviewFormData: Content {
    let reviewValue: Int
    let reviewTitle: String
    let reviewDescription: String
    let project: UUID
}

struct EditProjectContext: Encodable {
    let title = "Edit Project"
    let project: Project
    let types: [ApplicationType]
    let screenShots: [ScreenShot]
    let reviews: [Review]
    let skills: [Skill]
    let editing = true
}

struct UserFormData: Content {
    let name: String
    let username: String
    let biography: String
    let headshot: Data
    let isEmployed: Bool
}

struct EditUserContext: Encodable {
    let title = "Edit User"
    let user: User
    let editing = true
}


// MARK: - LOGIN

struct LoginContext: Encodable {
    let title = "Log In"
    let loginError: Bool
    init(loginError: Bool = false) {
        self.loginError = loginError
    }
}
