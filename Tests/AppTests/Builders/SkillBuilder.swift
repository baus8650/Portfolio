import Foundation

final class SkillBuilder {
    private var id = UUID()
    private var name = "Test Skill"
    
    func id(_ id: UUID) -> Self {
        self.id = id
        return self
    }
    
    func name(_ name: String) -> Self {
        self.name = name
        return self
    }
    
    func build() -> TestSkill {
        return TestSkill(id: id, name: name)
    }
}

struct TestSkill {
    var id: UUID
    var name: String
}
