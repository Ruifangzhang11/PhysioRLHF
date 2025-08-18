//
//  HealthAuth.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/13/25.
//

import HealthKit

enum HealthAuth {
    static let store = HKHealthStore()

    static func request(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else { completion(false); return }
        let readTypes: Set = [ HKObjectType.quantityType(forIdentifier: .heartRate)! ]
        store.requestAuthorization(toShare: [], read: readTypes) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }
}
