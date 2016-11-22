//
//  CJTracePanelView.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 16/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

class CJPointParam: NSObject {
    public var location: NSPoint
    public var time: CGFloat
    
    init(location: NSPoint, time: CGFloat) {
        self.location = location
        self.time = time
    }
}

protocol CJTracePanelDelegate {
    func CJTracePanelView(_ panel: CJTracePanelView, didUpdate pointParams: NSArray?)
}

class CJTracePanelView: NSView {
    
    var delegate: CJTracePanelDelegate?
    var isRecording: Bool = false
    
    var pointParamArr: NSMutableArray?
    fileprivate var timestamp: CGFloat?
    
    fileprivate var _timer: Timer?
    fileprivate let _timeInterval = 0.5
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let _backgroundColor = NSColor.white
        _backgroundColor.setFill()
        NSRectFill(dirtyRect)
        
        guard let _pointParamArr = pointParamArr else {
            return
        }
        
        if _pointParamArr.count < 2 {
            return
        }
        
        NSColor.black.set()
        let _figure = NSBezierPath()
        
        let _startPointParam = _pointParamArr.object(at: 0) as! CJPointParam
        let _startPoint = _startPointParam.location
        _figure.move(to: _startPoint)
        
        for i in 1...(_pointParamArr.count - 1) {
            let _pointParam = _pointParamArr.object(at: i) as! CJPointParam
            let _point = _pointParam.location
            _figure.line(to: _point)
        }
        
        _figure.lineWidth = 1.0
        _figure.stroke()
    }
    
    override func mouseDown(with event: NSEvent) {
        _logLocation(with: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        _logLocation(with: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        _logLocation(with: event)
    }
    
    func _logLocation(with event: NSEvent) {
//        let _location = event.locationInWindow
//        NSLog("(%f, %f)", _location.x, _location.y)
    }
}

extension CJTracePanelView {
    func startRecordMouseLoaction() {
        if ( isRecording ) {
            return
        }
        
        isRecording = true
        timestamp = 0.0
        pointParamArr = NSMutableArray()
        _timer = Timer.scheduledTimer(timeInterval: _timeInterval, target: self, selector: #selector(_recordCurrentMouseLocation), userInfo: nil, repeats: true)
    }
    
    func _recordCurrentMouseLocation() {
        let _location = self.window?.mouseLocationOutsideOfEventStream
        if let _location = _location {
            let _pointParam = CJPointParam(location: _location, time: timestamp!)
            pointParamArr?.add(_pointParam)
            
            if _checkPointIsOutside(point: _location) {
                _timer?.invalidate()
                _timer = nil
                isRecording = false
            }
        }
        
        timestamp = timestamp! + CGFloat(_timeInterval)
        _update()
        
        if (self.delegate != nil) {
            self.delegate?.CJTracePanelView(self, didUpdate: pointParamArr)
        }
    }
    
    func _update() {
        self.setNeedsDisplay(self.frame)
    }
    
    func _checkPointIsOutside(point: CGPoint) -> Bool {
        if ( point.x < self.frame.origin.x
            || point.x > self.frame.origin.x + self.bounds.width
            || point.y < self.frame.origin.y
            || point.y > self.frame.origin.y + self.bounds.height ) {
            return true
        }
        return false
    }
}
