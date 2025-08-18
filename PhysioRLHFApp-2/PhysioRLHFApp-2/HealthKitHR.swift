//
//  HealthKitHR.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/14/25.
//

// HealthKitHR.swift
import HealthKit
import Combine

final class HealthKitHR: NSObject {
    static let shared = HealthKitHR()

    private let store = HKHealthStore()
    private var anchor: HKQueryAnchor?
    private let subject = PassthroughSubject<Int, Never>()
    private var query: HKAnchoredObjectQuery?

    var stream: AnyPublisher<Int, Never> { subject.eraseToAnyPublisher() }

    func start() {
        guard HKHealthStore.isHealthDataAvailable(),
              let hrType = HKObjectType.quantityType(forIdentifier: .heartRate)
        else { return }

        // 只读授权：你之前的 HealthAuth.request 已经做了
        let pred = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-60*10),
                                               end: nil, options: .strictStartDate)

        // 初次拿历史 + 持续更新
        let q = HKAnchoredObjectQuery(type: hrType, predicate: pred,
                                      anchor: anchor, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, newAnchor, _ in
            self?.anchor = newAnchor
            self?.handle(samples: samples)
        }
        q.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            self?.anchor = newAnchor
            self?.handle(samples: samples)
        }
        store.execute(q)
        query = q
    }

    func stop() {
        if let q = query { store.stop(q) }
        query = nil
    }

    private func handle(samples: [HKSample]?) {
        guard let qs = samples as? [HKQuantitySample] else { return }
        for s in qs {
            let bpm = s.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
            subject.send(Int(bpm.rounded()))
        }
    }
}
