import Foundation

final class ProjectBuilder {
    private var id = UUID()
    private var name = "Test Project"
    private var yearCompleted = 2022
    
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
    
    func build() -> TestProject {
        return TestProject(id: id, name: name, yearCompleted: yearCompleted)
    }
}

struct TestProject {
    var id: UUID
    var name: String
    var yearCompleted: Int
}
