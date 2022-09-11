import XCTest
@testable import SaalApp

final class PresenterMock: ObjectsListPresentationLogic {
    var presentResponse: SaalApp.ObjectsList.Response?
    var displayResponse: SaalApp.ObjectsList.AddObject.Response?

    func present(response: SaalApp.ObjectsList.Response) {
        presentResponse = response
    }

    func displayObject(response: SaalApp.ObjectsList.AddObject.Response) {
        displayResponse = response
    }
}

final class ObjectsListInteractorTests: XCTestCase {
    var repository: InMemoryObjectsRepository!
    var presenter: PresenterMock!
    var sut: ObjectsListInteractor!

    override func setUp() {
        repository = InMemoryObjectsRepository()
        presenter = PresenterMock()
        sut = ObjectsListInteractor(
            presenter: presenter,
            objectsWorker: .init(objectsRepository: repository)
        )
    }

    func testAddObject() {
        sut.addObject(request: .init(type: .computer))

        sleep(1)
        XCTAssertEqual(repository.objects.count, 1)
        XCTAssertNotNil(presenter.displayResponse?.objectId)
    }

    func testAddMock() {
        sut.addMock(request: .init())

        sleep(1)
        XCTAssertEqual(repository.objects.count, 4)
    }

    func testLoadObjects() {
        let repository = InMemoryObjectsRepository()
        let presenter = PresenterMock()
        let sut = ObjectsListInteractor(
            presenter: presenter,
            objectsWorker: .init(objectsRepository: repository)
        )

        repository.objects = [
            Object(name: "Hello", description: "World", type: .desk),
            Object(name: "Hello", description: "World", type: .desk)
        ]

        sut.loadObjects(request: .init(filter: nil))

        sleep(1)
        XCTAssertEqual(repository.objects.count, 2)
    }

    func testDeleteObject() {
        let repository = InMemoryObjectsRepository()
        let presenter = PresenterMock()
        let sut = ObjectsListInteractor(
            presenter: presenter,
            objectsWorker: .init(objectsRepository: repository)
        )

        let id = UUID()
        repository.objects = [
            Object(id: id, name: "Hello", description: "World", type: .desk),
            Object(name: "Hello", description: "World", type: .desk)
        ]

        sut.deleteObject(request: .init(objectId: id))

        sleep(1)
        XCTAssertEqual(repository.objects.count, 1)
    }
}
