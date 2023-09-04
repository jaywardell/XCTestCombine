//
//  XCTestCase+Combine.swift
//  The_Big_3Tests_iOS
//
//  Created by Joseph Wardell on 10/30/22.
//

import XCTest
import Combine

public extension XCTestCase {
    
    func expectChanges<Type>(for publisher: AnyPublisher<Type, Never>, count expected: Int = 1, when callback: () async throws ->(), file: StaticString = #filePath, line: UInt = #line) async rethrows where Error == Error {
        
        var callCount = 0
        let expectation = XCTestExpectation(description: "expect changes for publisher")
        var bag = Set<AnyCancellable>()
        publisher.sink { _ in
            callCount += 1
            expectation.fulfill()
        }
        .store(in: &bag)
        
        try await callback()
        
        await fulfillment(of: [expectation], timeout: 1)
        
        XCTAssertEqual(callCount, expected, file: file, line: line)
    }

    func expectChanges<Type>(for publisher: AnyPublisher<Type, Never>, count expected: Int = 1, when callback: () throws ->(), file: StaticString = #filePath, line: UInt = #line) rethrows where Error == Error {
        
        var callCount = 0
        let expectation = XCTestExpectation(description: "expect changes for publisher")
        var bag = Set<AnyCancellable>()
        publisher.sink { _ in
            callCount += 1
            expectation.fulfill()
        }
        .store(in: &bag)
        
        try callback()
        
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(callCount, expected, file: file, line: line)
    }
    
    func expectChanges<E: Error>(for publisher: AnyPublisher<Void, E>, count expected: Int = 1, when callback: () throws ->(), file: StaticString = #filePath, line: UInt = #line) rethrows  {
        
        var callCount = 0
        let expectation = XCTestExpectation(description: "expect changes for publisher")
        var bag = Set<AnyCancellable>()
        publisher
            .catch { _ in
                PassthroughSubject<Void, Never>()
            }
            .sink { _ in
            callCount += 1
            expectation.fulfill()
        }
        .store(in: &bag)
        
        try callback()
        
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(callCount, expected, file: file, line: line)
    }

    func expectNoChanges<Type>(for publisher: AnyPublisher<Type, Never>, when callback: () throws ->(), file: StaticString = #filePath, line: UInt = #line) rethrows {
        
        var callCount = 0
        let expectation = XCTestExpectation(description: "expect changes for publisher")
        expectation.isInverted = true
        var bag = Set<AnyCancellable>()
        publisher.sink { _ in
            callCount += 1
            expectation.fulfill()
        }
        .store(in: &bag)
        
        try callback()
        
        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(callCount, 0, file: file, line: line)
    }

    func expectNoChanges<Type, Failure>(for publisher: some Publisher<Type, Failure>, when callback: () async throws ->(), file: StaticString = #filePath, line: UInt = #line) async rethrows {
        
        var callCount = 0
        let expectation = XCTestExpectation(description: "expect changes for publisher")
        expectation.isInverted = true
        var bag = Set<AnyCancellable>()
        publisher
            .assertNoFailure("this shouldn't have happened")
            .sink { _ in
            callCount += 1
            expectation.fulfill()
        }
        .store(in: &bag)
        
        try await callback()
        
        await fulfillment(of: [expectation], timeout: 1)

        XCTAssertEqual(callCount, 0, file: file, line: line)
    }

}
