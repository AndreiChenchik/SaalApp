import Foundation

protocol ObjectViewPresentationLogic {
    func present(response: ObjectView.Response)
    func present(response: ObjectView.StartAddRelation.Response)
}

final class ObjectViewInteractor {
    let presenter: ObjectViewPresentationLogic
    let objectsWorker: ObjectsWorker

    let objectId: UUID

    init(
        objectId: UUID,
        presenter: ObjectViewPresentationLogic,
        objectsWorker: ObjectsWorker
    ) {
        self.objectId = objectId
        self.presenter = presenter
        self.objectsWorker = objectsWorker
    }
}

// MARK: - ObjectsListBusinessLogic

extension ObjectViewInteractor: ObjectViewBusinessLogic {
    typealias Response = ObjectView.Response

    func loadObject(request: ObjectView.LoadObject.Request) {
        getObject(objectId: objectId) { [weak self] object in
            self?.presentObject(object)
        }
    }

    func updateField(request: ObjectView.UpdateField.Request) {
        let value = request.value
        let field = request.category

        getObject(objectId: objectId) { [weak self] in
            guard let self = self else { return }

            var object = $0

            switch field {
            case .description:
                object.description = value
            case .type:
                print("ufff")
            case .name:
                object.name = value
            }

            self.objectsWorker.updateObject(object) {_ in}
        }
    }

    func addRelation(request: ObjectView.AddRelation.Request) {
        let relationId = request.relationId

        getObject(objectId: objectId) { [weak self] in
            guard let self = self else { return }

            var object = $0

            object.relatedObjects.append(relationId)

            self.updateAndPresentObject(object)
        }
    }

    func removeRelation(request: ObjectView.RemoveRelation.Request) {
        getObject(objectId: objectId) { [weak self] in
            guard let self = self else { return }

            var object = $0

            object.relatedObjects = object.relatedObjects.filter {
                $0 != request.relationId
            }

            self.updateAndPresentObject(object)
        }
    }

    func startAddRelation(request: ObjectView.StartAddRelation.Request) {
        objectsWorker.fetchObjects { [weak self] in
            let response = ObjectView.StartAddRelation.Response(allObjects: $0)
            self?.presenter.present(response: response)
        }
    }
}

// MARK: - Helper

extension ObjectViewInteractor {
    private func getObject(
        objectId: UUID, completion: @escaping (Object) -> Void
    ) {
        objectsWorker.fetchObjects(
            filter: { $0.id == objectId },
            completion: { objects in
                if let object = objects.first {
                    completion(object)
                }
            }
        )
    }

    private func updateAndPresentObject(_ object: Object) {
        objectsWorker.updateObject(object) { [weak self] object in
            self?.presentObject(object)
        }
    }

    private func presentObject(_ object: Object) {
        self.objectsWorker.fetchObjects(
            filter: { object.relatedObjects.contains($0.id) },
            completion: { [weak self] relatedObjects in
                guard let self = self else { return }

                let response = Response(
                    object: object, relatedObjects: relatedObjects
                )

                self.presenter.present(response: response)
            }
        )
    }
}
