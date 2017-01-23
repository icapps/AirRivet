import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class ServiceQueueSpec: QuickSpec {

    override func spec() {
        describe("ServiceQueue") {

            var mockSession: MockAsyncSession!
            var service: ServiceQueue!
            let call = Call(path: "mock")
            let config = Configuration(baseURL: "mockService")
            var isFinalCalled = false

            beforeEach {
                isFinalCalled = false
                mockSession = MockAsyncSession()
                mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)
            }

            context("not started") {

                var taskSucceed = false
                beforeEach {
                    isFinalCalled = false
                    taskSucceed = false
                    service = ServiceQueue(configuration: config, faroSession: mockSession) { _ in
                        isFinalCalled = true
                        taskSucceed = true
                    }

                }

                it("add one") {
					let _ = try? service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in
                        taskSucceed = true
                    }) {_ in XCTFail()}
                    expect(service.hasOustandingTasks) == true
                    expect(taskSucceed).toNotEventually(beTrue())
                }

                it("add multiple") {
					expect {
						let task1 = try service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in
							taskSucceed = true
						}) {_ in XCTFail()}

						let task2 = try service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in
							taskSucceed = true
						}) {_ in XCTFail()}

						let task3 = try service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in
							taskSucceed = true
						}) {_ in XCTFail()}

						expect(service.hasOustandingTasks) == true
						expect(taskSucceed).toNotEventually(beTrue())
						expect(service.taskQueue) == [task1, task2, task3]
						return expect(isFinalCalled).toNotEventually(beTrue())
					}.toNot(throwError())
                }

                context("performWrite") {

                    it("should not be done without start") {
                        let _ = service.performWrite(call, autoStart: false) { _ in }
                        expect(service.hasOustandingTasks) == true
                    }
                }

            }

            context("started") {

                it("still start on autostart") {
                    service = ServiceQueue(configuration: config, faroSession: mockSession) { _ in
                        print("final")
                    }
                    waitUntil { done in
						let _ = try? service.perform(call, autoStart: true, success: { (_: Success<MockModel>) in
                            expect(service.hasOustandingTasks) == false
                            done()
                        })
                    }
                }

                context("multiple") {
                    var task1: URLSessionDataTask!
                    var task2: URLSessionDataTask!
                    var task3: URLSessionDataTask!

                    var failedTasks: Set<URLSessionTask>?

                    beforeEach {
						do {
							isFinalCalled = false
							service = ServiceQueue(configuration: config, faroSession: mockSession) { failures in
								isFinalCalled = true
								failedTasks = failures
							}

							task1 = try service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in })
							task2 = try service.perform(call, autoStart: true, success: { (_: Success<MockModel>) in })
							task3 = try service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in })
						} catch {
							XCTFail("\(error)")
						}
                                            }

                    it("not have failedTasks") {
                        expect(failedTasks).to(beNil())
                    }

                    it("autoStart one") {
                        expect(service.taskQueue).to(contain([task1, task2, task3]))
                        expect(service.taskQueue).toNotEventually(contain([task2]))
                        expect(service.taskQueue).toEventually(contain([task1, task3]))
                    }

                    it("one extra") {
                        service.resume(task3)
                        expect(service.taskQueue).to(contain([task1, task2, task3]))
                        expect(service.taskQueue).toNotEventually(contain([task2, task3]))
                        expect(service.taskQueue).toEventually(contain([task1]))
                    }

                    it("all") {
                        service.resumeAll()
                        expect(service.taskQueue).to(contain([task1, task2, task3]))
                        expect(service.taskQueue).toNotEventually(contain([task1, task3]))
                    }

                    context("invalidate") {

                        it("removeAll") {
                            expect(service.hasOustandingTasks) == true
                            service.invalidateAndCancel()
                            expect(service.hasOustandingTasks) == false
                        }

                    }

                    context("final") {

                        it("all completed") {
                            service.resumeAll()
                            expect(isFinalCalled) == false
                            expect(isFinalCalled).toEventually(beTrue())
                        }

                        it("some completed") {
                            service.resume(task3)
                            expect(isFinalCalled) == false
                            expect(isFinalCalled).toNotEventually(beTrue())
                        }
                    }

                    context("some fail") {

                        var fail1: MockURLSessionTask!

                        beforeEach {
							do {
								fail1 = try service.perform(call, autoStart: false, success: { (_: Success<MockModel>) in }) as? MockURLSessionTask
								mockSession.tasksToFail = [fail1]
							} catch {
								XCTFail("\(error)")
							}
						}

                        it("should queue the failed task") {
                            expect(service.taskQueue).to(contain(fail1))
                            expect(mockSession.tasksToFail).to(contain(fail1))
                        }

                        it("should report failure in final") {
                            service.resumeAll()
                            expect(failedTasks?.first).toEventually(equal(fail1))
                        }

                    }

                }
            }

        }
    }

}
