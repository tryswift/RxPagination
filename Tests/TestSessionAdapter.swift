import Foundation
import APIKit

class TestSessionAdapter: SessionAdapter {
    class Task: SessionTask {
        let handler: (Data?, URLResponse?, Error?) -> Void

        init(handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.handler = handler
        }

        func resume() {}
        func cancel() {}
    }

    var tasks = [Task]()

    func `return`(data: Data) {
        guard !tasks.isEmpty else {
            return
        }

        let task = tasks.removeFirst()
        let urlResponse = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)

        task.handler(data, urlResponse, nil)
    }

    // MARK: SessionAdapterType
    func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask {
        let task = Task(handler: handler)
        tasks.append(task)
        return task
    }

    func getTasks(with handler: @escaping ([SessionTask]) -> Void) {
        handler([])
    }
}
