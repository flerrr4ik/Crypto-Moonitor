//
//  BalloonMarker.swift
//  Crypto Moonitor
//
//  Created by Andrii Pyrskyi on 27.05.2025.
//

import DGCharts
import UIKit

class ChartValueMarker: MarkerImage {
    
    // MARK: - Properties
    
    private var color: UIColor
    private var font: UIFont
    private var textColor: UIColor
    private var insets: UIEdgeInsets
    private var minimumSize = CGSize()
    
    private var label: String = ""
    private var labelSize: CGSize = .zero
    private var paragraphStyle: NSMutableParagraphStyle?
    private var drawAttributes = [NSAttributedString.Key: Any]()
    
    // MARK: - Initialization
    
    init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        super.init()
        setupParagraphStyle()
    }
    
    private func setupParagraphStyle() {
        paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.alignment = .center
    }
    
    // MARK: - MarkerImage Overrides
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let size = self.size
        var offset = self.offset
        var origin = point
        
        origin.x -= size.width / 2
        origin.y -= size.height
        
        adjustOffsetForXAxis(&offset, origin: origin, size: size)
        adjustOffsetForYAxis(&offset, origin: origin, size: size)
        
        return offset
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        guard chartView != nil else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(x: point.x + offset.x, y: point.y + offset.y),
            size: size
        )
        
        drawBackground(context: context, rect: rect)
        drawLabel(context: context, rect: &rect)
    }
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        setLabelText(entry.y)
        configureDrawAttributes()
        calculateLabelSize()
        updateMarkerSize()
    }
    
    // MARK: - Drawing Methods
    
    private func drawBackground(context: CGContext, rect: CGRect) {
        context.saveGState()
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        context.restoreGState()
    }
    
    private func drawLabel(context: CGContext, rect: inout CGRect) {
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        label.draw(in: rect, withAttributes: drawAttributes)
        UIGraphicsPopContext()
    }
    
    // MARK: - Offset Calculation
    
    private func adjustOffsetForXAxis(_ offset: inout CGPoint, origin: CGPoint, size: CGSize) {
        if origin.x + offset.x < 0.0 {
            offset.x = -origin.x
        } else if let chart = self.chartView,
                  origin.x + size.width + offset.x > chart.bounds.size.width {
            offset.x = chart.bounds.size.width - origin.x - size.width
        }
    }
    
    private func adjustOffsetForYAxis(_ offset: inout CGPoint, origin: CGPoint, size: CGSize) {
        if origin.y + offset.y < 0 {
            offset.y = -origin.y
        } else if let chart = self.chartView,
                  origin.y + size.height + offset.y > chart.bounds.size.height {
            offset.y = chart.bounds.size.height - origin.y - size.height
        }
    }
    
    // MARK: - Content Configuration
    
    private func setLabelText(_ value: Double) {
        label = String(format: "%.2f", value)
    }
    
    private func configureDrawAttributes() {
        drawAttributes.removeAll()
        drawAttributes[.font] = font
        drawAttributes[.paragraphStyle] = paragraphStyle
        drawAttributes[.foregroundColor] = textColor
    }
    
    private func calculateLabelSize() {
        labelSize = label.size(withAttributes: drawAttributes)
    }
    
    private func updateMarkerSize() {
        self.size = CGSize(
            width: labelSize.width + insets.left + insets.right,
            height: labelSize.height + insets.top + insets.bottom
        )
    }
}
