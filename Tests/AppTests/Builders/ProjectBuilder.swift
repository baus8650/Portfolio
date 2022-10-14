import Foundation

final class ProjectBuilder {
    private var id = UUID()
    private var name = "Test Project"
    private var yearCompleted = 2022
    private var shortDescription = "Short description"
    private var longDescription = "Long description"
    private var appLink = "App link"
    private var repoLink = "Repo link"
    private var appIcon = "App icon"
    private var applicationType = UUID()
    
    func id(_ id: UUID) -> Self {
        self.id = id
        return self
    }
    
    func name(_ name: String) -> Self {
        self.name = name
        return self
    }
    
    func yearCompleted(_ yearCompleted: Int) -> Self {
        self.yearCompleted = yearCompleted
        return self
    }
    
    func shortDescription(_ shortDescription: String) -> Self {
        self.shortDescription = shortDescription
        return self
    }
    
    func longDescription(_ longDescription: String) -> Self {
        self.longDescription = longDescription
        return self
    }
    
    func appLink(_ appLink: String) -> Self {
        self.appLink = appLink
        return self
    }
    
    func repoLink(_ repoLink: String) -> Self {
        self.repoLink = repoLink
        return self
    }
    
    func appIcon(_ appIcon: String) -> Self {
        self.appIcon = appIcon
        return self
    }
    
    func applicationType(_ applicationType: UUID) -> Self {
        self.applicationType = applicationType
        return self
    }
    
    func build() -> TestProject {
        return TestProject(id: id, name: name, yearCompleted: yearCompleted, shortDescription: shortDescription, longDescription: longDescription, appLink: appLink, repoLink: repoLink, appIcon: appIcon, applicationType: applicationType)
    }
}

struct TestProject {
    var id: UUID
    var name: String
    var yearCompleted: Int
    var shortDescription: String
    var longDescription: String
    var appLink: String
    var repoLink: String
    var appIcon: String
    var applicationType: UUID
}
