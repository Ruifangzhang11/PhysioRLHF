//
//  HREmulator.swift
//  PhysioRLHFApp-2
//
//  Created by Ruifang Zhang on 8/8/25.
//

import Foundation
import Combine

/// 模拟心率流：每5秒输出一个“心率值”，范围 65~95 bpm
final class HREmulator {
    static let shared = HREmulator()

    private let subject = PassthroughSubject<Int, Never>()
    var stream: AnyPublisher<Int, Never> { subject.eraseToAnyPublisher() }

    private var timer: Timer?
    private var current = 75

    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self else { return }
            // 随机上下波动 0~6
            let delta = Int.random(in: -6...6)
            current = max(60, min(100, current + delta))
            subject.send(current)
        }
        // 立即发一个初始值
        subject.send(current)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
