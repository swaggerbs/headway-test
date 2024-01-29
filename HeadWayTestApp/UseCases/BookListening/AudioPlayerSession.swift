//
//  AudioPlayerSession.swift
//  HeadWayTestApp
//

import Foundation
import Combine
import AVKit

final class AudioPlayerSession {
    
    private let player: AVPlayer
    
    private let currentTimeSubject = PassthroughSubject<Float64, Never>()
    var currentTime: AnyPublisher<Float64, Never> {
        currentTimeSubject.eraseToAnyPublisher()
    }
    
    private(set)var state: AnyPublisher<Status, Never>?
    
    private var speeds = AVPlaybackSpeed.systemDefaultSpeeds
    
    var currentSpeedLocalized: String {
        speeds[currentSpeedIndex].localizedNumericName
    }
    private var currentSpeedIndex: Int
    
    enum Status {
        case readyToPlay
        case unknown
        case failed
    }
    
    init() {
        player = AVPlayer()
        currentSpeedIndex = speeds.firstIndex {
            $0.rate == 1
        } ?? 0
        addTimeObserver()
    }
    
    func getDuration() async throws -> Float64 {
        guard let item = player.currentItem else {
            return .zero
        }
        let duration = try await item.asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        return seconds
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func nextSpeed() {
        let nextIndex = currentSpeedIndex + 1
        if nextIndex == speeds.count {
            currentSpeedIndex = 0
        } else {
            currentSpeedIndex = nextIndex
        }
        player.rate = speeds[currentSpeedIndex].rate
    }
    
    func seek(to timeInterval: TimeInterval) async {
        let targetTime = CMTimeMake(value: Int64(timeInterval), timescale: 1)
        player.currentTime()
        await player.seek(to: targetTime)
    }
    
    func seekBackward(for timeInterval: TimeInterval) async {
        let playerCurrenTime = CMTimeGetSeconds(player.currentTime())
        var newTime = playerCurrenTime - timeInterval
        if newTime < 0 {
            newTime = 0
        }
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        await player.seek(to: selectedTime)
    }
    
    func seekForward(for timeInterval: TimeInterval) async {
        guard let duration = player.currentItem?.duration else {
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + timeInterval
        guard newTime < CMTimeGetSeconds(duration) else {
            return
        }
        let selectedTime: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)
        await player.seek(to: selectedTime)
    }
    
    func replaceItem(assetUrl: URL) {
        let item = AVPlayerItem(url: assetUrl)
        state = item.publisher(for: \.status)
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .map { status in
                    switch status {
                    case .readyToPlay:
                        return .readyToPlay
                    case .failed:
                        return .failed
                    default:
                        return .unknown
                    }
                }
                .eraseToAnyPublisher()
        player.replaceCurrentItem(with: item)
    }
    
    private func addTimeObserver() {
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            if self?.player.currentItem?.status == .readyToPlay {
                self?.currentTimeSubject.send(CMTimeGetSeconds(time))
            }
            
        }
    }
}
