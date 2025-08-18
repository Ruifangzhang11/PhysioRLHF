//
//  WatchHealthAuth.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/15/25.
//

import HealthKit
import WatchConnectivity

final class WatchHealthAuth {
    static let shared = WatchHealthAuth()
    let store = HKHealthStore()

    private init() {}

    func request(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(false); return }

        let toShare: Set = [HKObjectType.workoutType()]
        let toRead: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]

        store.requestAuthorization(toShare: toShare, read: toRead) { ok, _ in
            completion(ok)
        }
    }
}
