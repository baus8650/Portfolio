import Foundation

final class ApplicationTypeBuilder {
    private var id = UUID()
    private var name = "iOS Application"
    
    func id(_ id: UUID) -> Self {
        self.id = id
        return self
    }
    
    func name(_ name: String) -> Self {
        self.name = name
        return self
    }
    
    func build() -> TestApplicationType {
        return TestApplicationType(id: id, name: name)
    }
}

struct TestApplicationType {
    var id: UUID
    var name: String
}
