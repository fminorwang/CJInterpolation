//
//  ViewController.swift
//  QTFeatureAdPathGenerator
//
//  Created by fminor on 16/11/2016.
//  Copyright © 2016 fminor. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, CJTracePanelDelegate {

    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var drawPanel: CJTracePanelView!
    
    var startTime = 7.0
    var originPoint: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _click = NSClickGestureRecognizer(target: self, action: #selector(gestureHandler(sender:)))
        drawPanel.addGestureRecognizer(_click)
        drawPanel.delegate = self
        drawPanel.startRecordClickLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(_actionInterpolate),
                                               name: NSNotification.Name(rawValue: kNotificationNameStartInterpolation), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_actionClear),
                                               name: NSNotification.Name(rawValue: kNotificationNameClearInterpolation), object: nil)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.view.window?.titlebarAppearsTransparent = true
        self.view.window?.styleMask.insert(.unifiedTitleAndToolbar)
        
        let _titleBar = self.storyboard?.instantiateController(withIdentifier: "titleBarController") as! NSTitlebarAccessoryViewController
        self.view.window?.addTitlebarAccessoryViewController(_titleBar)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func gestureHandler(sender: NSGestureRecognizer) {
        if drawPanel.isRecording == false {
            drawPanel.startRecordMouseLoaction()
        }
    }

    func CJTracePanelView(_ panel: CJTracePanelView, didUpdate pointParams: [CJPointParam]?) {
        _log(pointParams: pointParams)
    }
    
    func _log(pointParams: [CJPointParam]? ) {
        if let _pointParams = pointParams {
            var _logString = String()
            for _pointParam in _pointParams {
                
                let _convertedParam = _convertPointParam(from: _pointParam, width: 1080.0, height: 270.0)
                let _location = _convertedParam.location
                let _time = _convertedParam.time
                
                _logString = _logString.appendingFormat("%.02f, %.02f, %.02f;", _location.x, _location.y, _time)
            }
            textView.string = _logString
        }
    }
    
    func _convertPointParam(from origin: CJPointParam, width containerWidth: CGFloat, height containerHeight: CGFloat) -> CJPointParam {
        var _convertedPoint = CGPoint.zero
        
        if let _originPoint = originPoint {
            let _ratio_x = containerWidth / ( drawPanel.bounds.width - _originPoint.x )
            let _ratio_y = containerHeight / _originPoint.y
            let _x = ( origin.location.x - _originPoint.x ) * _ratio_x
            let _y = ( _originPoint.y - origin.location.y ) * _ratio_y
            _convertedPoint.x = _x
            _convertedPoint.y = _y
        } else {
            originPoint = origin.location
            _convertedPoint = originPoint!
        }
        
        return CJPointParam(location: _convertedPoint, time: CGFloat(startTime) + origin.time)
    }
    
    func _actionCompute() {
        guard let points = drawPanel.fixedParamArr else {
            return
        }
//        let _computorx = CJSplineInterpolation()
//        let _computory = CJSplineInterpolation()
        let _computorx = CJPolynomialInterpolation()
        let _computory = CJPolynomialInterpolation()
        var _array_x = Array<CJInterpolationPoint<Double>>()
        var _array_y = Array<CJInterpolationPoint<Double>>()
        for i in 0...points.count - 1 {
            let _point = points[i]
            let _t = _point.time
            let _x = _point.location.x
            let _y = _point.location.y
            
            _array_x.append(CJInterpolationPoint(input: Double(_t), value: Double(_x)))
            _array_y.append(CJInterpolationPoint(input: Double(_t), value: Double(_y)))
        }
        
        _computorx.fixedPoints = _array_x
        _computory.fixedPoints = _array_y
        
        _computorx.solve()
        _computory.solve()
        
        var _newArr = [CJPointParam]()
        for i in stride(from: 0.0, to: points.last!.time + 0.01, by: 0.01) {
            let _location = NSPoint(x: _computorx.interpolate(at: Double(i)), y: _computory.interpolate(at: Double(i)))
            let _point = CJPointParam(location: _location, time: i)
            _newArr.append(_point)
        }
        drawPanel.pointParamArr = _newArr
        drawPanel.setNeedsDisplay(drawPanel.frame)
        drawPanel.stopRecordClickLocation()
        
        _log(pointParams: _newArr)
    }
    
    func _actionInterpolate() -> Void {
        _actionCompute()
    }
    
    func _actionClear() {
        drawPanel.clear()
        textView.string = ""
    }
}

