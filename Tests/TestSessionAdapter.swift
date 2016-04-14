import Foundation
import APIKit

class TestSessionAdapter: SessionAdapterType {
    class Task: SessionTaskType {
        let handler: (NSData?, NSURLResponse?, NSError?) -> Void

        init(handler: (NSData?, NSURLResponse?, NSError?) -> Void) {
            self.handler = handler
        }

        func cancel() {

        }
    }

    var tasks = [Task]()

    func returnData(data: NSData? = NSData(), URLResponse: NSURLResponse? = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil), error: NSError? = nil) {
        guard !tasks.isEmpty else {
            return
        }

        let task = tasks.removeFirst()
        task.handler(data, URLResponse, error)
    }

    // MARK: SessionAdapterType
    func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType {
        let task = Task(handler: handler)
        tasks.append(task)

        return task
    }

    func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        handler([])
    }
}
