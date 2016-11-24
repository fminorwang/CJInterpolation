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

enum InputMode {
    case pan
    case click
}

protocol CJTracePanelDelegate {
    func CJTracePanelView(_ panel: CJTracePanelView, didUpdate pointParams: NSArray?)
}

class CJTracePanelView: NSView {
    
    var delegate: CJTracePanelDelegate?
    
    var _inputMode: InputMode = .click
    
    var isRecording: Bool = false
    
    fileprivate var _timer: Timer?
    fileprivate let _timeInterval = 0.5
    fileprivate var timestamp: CGFloat?
    
    var pointParamArr: NSMutableArray?
    var fixedParamArr: Array<CJPointParam>?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        let _backgroundColor = NSColor.white
        _backgroundColor.setFill()
        NSRectFill(dirtyRect)
        
        NSColor.black.set()
        var _figure = NSBezierPath()
        
        if let _fixedParamArr = fixedParamArr {
            for pointParam in _fixedParamArr {
                NSColor.red.setFill()
                NSColor.white.setStroke()
                _figure.appendRect(NSRect(x: pointParam.location.x - 3.0, y: pointParam.location.y - 3.0, width: 6.0, height: 6.0))
                _figure.fill()
                _figure = NSBezierPath()
            }
            
            if self.isRecording && _fixedParamArr.count > 1 {
                let _firstPoint = _fixedParamArr[0]
                _figure.move(to: _firstPoint.location)
                for pointParam in _fixedParamArr {
                    _figure.line(to: pointParam.location)
                }
                NSColor.black.setStroke()
                _figure.lineWidth = 1.0
                _figure.stroke()
                _figure = NSBezierPath()
            }
        }
        
        guard let _pointParamArr = pointParamArr else {
            return
        }
        
        if _pointParamArr.count < 2 {
            return
        }
        
        let _startPointParam = _pointParamArr.object(at: 0) as! CJPointParam
        let _startPoint = _startPointParam.location
        _figure.move(to: _startPoint)
        
        for i in 1...(_pointParamArr.count - 1) {
            let _pointParam = _pointParamArr.object(at: i) as! CJPointParam
            let _point = _pointParam.location
            _figure.line(to: _point)
        }
        
        NSColor.black.setStroke()
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
        
    }
}

// click mode
extension CJTracePanelView {
    func startRecordClickLocation() {
        _inputMode = .click
        if ( isRecording ) {
            return
        }
        
        isRecording = true
        timestamp = 0.0
        pointParamArr = NSMutableArray()
        fixedParamArr = Array()
        
        let _clickGesture = NSClickGestureRecognizer(target: self, action: #selector(_actionClick))
        objc_setAssociatedObject(self, "click_gesture", _clickGesture, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.addGestureRecognizer(_clickGesture)
    }
    
    func stopRecordClickLocation() -> Void {
        isRecording = false
        let _clickGesture = objc_getAssociatedObject(self, "click_gesture")
        if let _clickGesture = _clickGesture {
            self.removeGestureRecognizer(_clickGesture as! NSGestureRecognizer)
        }
        timestamp = 0.0
        pointParamArr = NSMutableArray()
        fixedParamArr = Array()
    }
    
    func _actionClick() -> Void {
        let _location = self.window?.mouseLocationOutsideOfEventStream
        if let _location = _location {
            let _pointParam = CJPointParam(location: _location, time: timestamp!)
            fixedParamArr?.append(_pointParam)
        }
        
        timestamp = timestamp! + CGFloat(_timeInterval)
        self.setNeedsDisplay(self.frame)
    }
}

// pan mode
extension CJTracePanelView {
    func startRecordMouseLoaction() {
        if ( isRecording ) {
            return
        }
        
        _inputMode = .pan
        isRecording = true
        timestamp = 0.0
        pointParamArr = NSMutableArray()
        fixedParamArr = Array()
        _timer = Timer.scheduledTimer(timeInterval: _timeInterval, target: self, selector: #selector(_recordCurrentMouseLocation), userInfo: nil, repeats: true)
    }
    
    func _recordCurrentMouseLocation() {
        let _location = self.window?.mouseLocationOutsideOfEventStream
        if let _location = _location {
            let _pointParam = CJPointParam(location: _location, time: timestamp!)
            fixedParamArr?.append(_pointParam)
            
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
