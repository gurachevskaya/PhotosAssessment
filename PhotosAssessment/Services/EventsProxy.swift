//
//  EventsProxy.swift
//  PhotosAssessment
//
//  Created by Karina gurachevskaya on 29.09.22.
//

import Foundation
import Photos

protocol EventsDelegate: AnyObject {
    func didChangeGallery(results: PHFetchResult<PHAsset>)
}

protocol EventsDelegateHandler: AnyObject {
    var delegate: EventsDelegate? { get set }
}

protocol EventsActionHandler {
    func actionChangeGallery(results: PHFetchResult<PHAsset>)
}

protocol EventsProxy: EventsActionHandler, EventsDelegateHandler {}

final class EventsProxyImp: EventsProxy {
    weak var delegate: EventsDelegate? {
        didSet {
            delegates.addObject(delegate)
        }
    }
    fileprivate var delegates = NSPointerArray.weakObjects()

    func actionChangeGallery(results: PHFetchResult<PHAsset>) {
        delegates.compact()

        for index in 0..<delegates.count {
            if let delegate = delegates.object(at: index) as? EventsDelegate {
                delegate.didChangeGallery(results: results)
            }
        }
    }
}

