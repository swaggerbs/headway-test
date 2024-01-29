//
//  BookListeningGateway.swift
//  HeadWayTestApp
//

import AVKit
import Combine

struct AudioPlayerSession {
    
    private let player: AVPlayer
    private let item: AVPlayerItem
    
    private let subject = PassthroughSubject<Float64, Never>()
    var currentTime: AnyPublisher<Float64, Never> {
        subject.eraseToAnyPublisher()
    }
    
    init(url: URL) {
        item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        addTimeObserver()
    }
    
    func getDuration() async throws -> Float64 {
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
    
    func seek(to timeInterval: TimeInterval) async {
        let targetTime = CMTimeMake(value: Int64(timeInterval), timescale: 1)
        await player.seek(to: targetTime)
    }
    
    private func addTimeObserver() {
        let interval = CMTimeMakeWithSeconds(1, preferredTimescale: 1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            if player.currentItem?.status == .readyToPlay {
                subject.send(CMTimeGetSeconds(time))
            }
            
        }
    }
}
