//
//  SDStickyHeader.swift
//
//  Created by Sazan Dauti on 5/20/17.
//  Copyright © 2017 Sazan Dauti. All rights reserved.
//

import UIKit

class SDStickyHeader: UIView, UIScrollViewDelegate {
    
    ////////////////////////////////////////////////////
    //////////////////// STRUCTS ///////////////////////
    ////////////////////////////////////////////////////
    
    private struct SDBGObj {
        var view: UIView!
    }
    
    private struct SDHeadObj {
        var view: UIView!
        var originalOffset: CGFloat?
        var downRatio: CGFloat?
        var upRatio: CGFloat?
        var startAlpha: CGFloat?
        var endAlpha: CGFloat?
        var startFrame: CGRect!
        var endFrame: CGRect?
    }
    
    
    ////////////////////////////////////////////////////
    /////////////////// VARIABLES //////////////////////
    ////////////////////////////////////////////////////
    
    var scroller: UIScrollView!
    private var headerHeight: CGFloat!
    
    private var minimumHeaderHeight: CGFloat = 0
    private var maxHeight: CGFloat = 0
    
    private var headerBackground: UIView!
    private var headerBackgroundCover: UIView!
    
    private var headerColor: UIColor!
    private var colorStartAlpha: CGFloat!
    private var colorEndAlpha: CGFloat!
    
    private var headerBackgroundElements: [SDBGObj] = []
    private var headerElements: [SDHeadObj] = []
    
    
    ////////////////////////////////////////////////////
    ///////////////// INIT FUNCTIONS ///////////////////
    ////////////////////////////////////////////////////
    
    public init(frame: CGRect, headerHeight: CGFloat) {
        super.init(frame: frame)
        self.scroller = UIScrollView(frame: frame)
        self.setUpScroller(headerHeight: headerHeight)
    }
    
    public init(scrollView: UIScrollView, headerHeight: CGFloat) {
        super.init(frame: scrollView.frame)
        self.scroller = scrollView
        self.setUpScroller(headerHeight: headerHeight)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    ////////////////////////////////////////////////////
    //////////////// HELPER FUNCTIONS //////////////////
    ////////////////////////////////////////////////////
    
    private func setUpScroller(headerHeight: CGFloat) {
        self.headerHeight = headerHeight
        self.headerBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.scroller.frame.width, height: self.headerHeight))
        self.headerBackground.clipsToBounds = true
        self.headerBackground.isUserInteractionEnabled = false
        
        self.headerBackgroundCover = UIView(frame: self.headerBackground.frame)
        self.headerBackground.addSubview(self.headerBackgroundCover)
        
        self.scroller.contentInset.top = headerHeight
        self.scroller.scrollIndicatorInsets.top = headerHeight
        self.scroller.contentOffset.y = -headerHeight
        self.scroller.delegate = self
        
        super.addSubview(self.scroller)
        super.addSubview(self.headerBackground)
    }
    
    private func linearTransform(start1: CGFloat, end1: CGFloat, start2: CGFloat, end2: CGFloat, pos: CGFloat) -> CGFloat {
        let slope = (start2 - end2) / (start1 - end1)
        let y_intercept = start2 - slope * start1
        return slope * pos + y_intercept
    }
    
    private func checkUserInteraction(_ view: UIView) {
        if view is UIButton || view.isUserInteractionEnabled {
            self.headerBackground.isUserInteractionEnabled = true
        }
    }
    
    ////////////////////////////////////////////////////
    ////////////////// USER FUNCTIONS //////////////////
    ////////////////////////////////////////////////////
    
    
    /**
     This function places a view in the scrollView
     The scrollView is then resized
     */
    
    public func addToScroller(_ view: UIView) {
        self.scroller.addSubview(view)
        let tempHeight = view.frame.origin.y + view.frame.height
        if tempHeight > self.maxHeight {
            self.maxHeight = tempHeight
            self.scroller.contentSize.height = self.maxHeight
        }
    }
    
    
    /**
     This function simply places a backgroundImageView in the backgroundView
     */
    
    public func setBackground(image: UIImage) {
        let tempBg = UIImageView()
        tempBg.frame = self.headerBackground.frame
        tempBg.contentMode = .scaleAspectFill
        tempBg.image = image
        
        if self.headerBackgroundElements.count > 0 {
            self.headerBackground.insertSubview(tempBg, belowSubview: self.headerBackgroundElements[0].view)
        } else {
            self.headerBackground.insertSubview(tempBg, belowSubview: self.headerBackgroundCover)
        }
        
        self.headerBackgroundElements.append(SDBGObj(view: tempBg))
    }
    
    
    /**
     This function simply changes the background color of the backgroundView
     */
    
    public func setBackground(color: UIColor) {
        self.headerBackground.backgroundColor = color
    }
    
    
    /**
     This function places a view in the background... It makes the frame = background frame
     It also resizes on scroll (just like the background)
     */
    
    public func addBackgroundElement(_ view: UIView) {
        self.checkUserInteraction(view)
        let tempView = view
        tempView.frame = self.headerBackground.frame
        self.headerBackgroundElements.append(SDBGObj(view: tempView))
        self.headerBackground.insertSubview(tempView, belowSubview: self.headerBackgroundCover)
    }
    
    
    /**
     This function places a view in the header. This view has a fixed position
     so it doesn't move on scroll
     */
    
    public func addHeaderElement(_ view: UIView) {
        self.checkUserInteraction(view)
        self.headerBackgroundCover.addSubview(view)
    }
    
    
    /**
     This function places a view in the header. This view has a dynamic position
     so it moves on scroll. The speed depends on the downRatio and upRatio.
     The downRatio is for when the object is set to move downward and the upRatio
     is for when the object is set to move upwards.
     */
    
    public func addHeaderElement(_ view: UIView, downRatio: CGFloat, upRatio: CGFloat) {
        self.createHeaderElement(view, originalOffset: view.frame.origin.y, downRatio: downRatio, upRatio: upRatio, startAlpha: nil, endAlpha: nil, endFrame: nil)
    }
    
    public func addHeaderElement(_ view: UIView, downRatio: CGFloat, upRatio: CGFloat, startAlpha: CGFloat, endAlpha: CGFloat) {
        self.createHeaderElement(view, originalOffset: view.frame.origin.y, downRatio: downRatio, upRatio: upRatio, startAlpha: startAlpha, endAlpha: endAlpha, endFrame: nil)
    }
    
    public func addHeaderElement(_ view: UIView, endFrame: CGRect) {
        self.createHeaderElement(view, originalOffset: nil, downRatio: nil, upRatio: nil, startAlpha: nil, endAlpha: nil, endFrame: endFrame)
    }
    
    public func addHeaderElement(_ view: UIView, endFrame: CGRect, downRatio: CGFloat) {
        self.createHeaderElement(view, originalOffset: nil, downRatio: downRatio, upRatio: nil, startAlpha: nil, endAlpha: nil, endFrame: endFrame)
    }
    
    public func addHeaderElement(_ view: UIView, endFrame: CGRect, startAlpha: CGFloat, endAlpha: CGFloat) {
        self.createHeaderElement(view, originalOffset: nil, downRatio: nil, upRatio: nil, startAlpha: startAlpha, endAlpha: endAlpha, endFrame: endFrame)
    }
    
    public func addHeaderElement(_ view: UIView, endFrame: CGRect, downRatio: CGFloat, startAlpha: CGFloat, endAlpha: CGFloat) {
        self.createHeaderElement(view, originalOffset: nil, downRatio: downRatio, upRatio: nil, startAlpha: startAlpha, endAlpha: endAlpha, endFrame: endFrame)
    }
    
    private func createHeaderElement(_ view: UIView, originalOffset: CGFloat?, downRatio: CGFloat?, upRatio: CGFloat?, startAlpha: CGFloat?, endAlpha: CGFloat?, endFrame: CGRect?) {
        self.checkUserInteraction(view)
        view.alpha = startAlpha ?? 1
        self.headerBackgroundCover.addSubview(view)
        let obj = SDHeadObj(view: view, originalOffset: originalOffset, downRatio: downRatio, upRatio: upRatio, startAlpha: startAlpha, endAlpha: endAlpha, startFrame: view.frame, endFrame: endFrame)
        self.headerElements.append(obj)
    }
    
    
    /**
     This function sets the minimum height of the header (0 is the default)
     */
    
    public func setHeaderMinimumHeight(_ minHeight: CGFloat) {
        self.minimumHeaderHeight = minHeight
    }
    
    
    /**
     This function sets a color fade from startAlpha to endAlpha as the header moves up.
     */
    
    public func fadeToColor(_ color: UIColor, startAlpha: CGFloat, endAlpha: CGFloat) {
        self.headerColor = color
        self.colorStartAlpha = startAlpha
        self.colorEndAlpha = endAlpha
        self.headerBackgroundCover.backgroundColor = color.withAlphaComponent(startAlpha)
    }
    
    
    ////////////////////////////////////////////////////
    /////////// SCROLLVIEW DELEGATE FUNCTIONS //////////
    ////////////////////////////////////////////////////
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y_offset = scrollView.contentOffset.y
        
        if y_offset <= -self.headerHeight {
            self.headerBackground.frame.size.height = -y_offset
            
            for element in self.headerElements {
                
                if element.originalOffset != nil {
                    element.view.frame.origin.y = element.originalOffset! - (y_offset + self.headerHeight)/element.downRatio!
                } else if element.endFrame != nil {
                    element.view.frame = element.startFrame
                    if element.downRatio != nil {
                        element.view.frame.origin.y = element.startFrame.origin.y - (y_offset + self.headerHeight)/element.downRatio!
                    }
                }
                
                if element.startAlpha != nil && element.endAlpha != nil {
                    element.view.alpha = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: element.startAlpha!, end2: element.endAlpha!, pos: -y_offset)
                }
                
            }
            
            if self.headerColor != nil {
                self.headerBackgroundCover.backgroundColor = self.headerColor.withAlphaComponent(self.colorStartAlpha)
            }
            
        } else if y_offset <= -self.minimumHeaderHeight {
            self.headerBackground.frame.size.height = -y_offset
            
            for element in self.headerElements {
                
                if element.originalOffset != nil {
                    element.view.frame.origin.y = element.originalOffset! - (y_offset + self.headerHeight)/element.upRatio!
                } else if element.endFrame != nil {
                    element.view.frame.origin.y = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: element.startFrame.origin.y, end2: element.endFrame!.origin.y, pos: -y_offset)
                    element.view.frame.origin.x = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: element.startFrame.origin.x, end2: element.endFrame!.origin.x, pos: -y_offset)
                    element.view.frame.size.height = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: element.startFrame.height, end2: element.endFrame!.height, pos: -y_offset)
                    element.view.frame.size.width = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: element.startFrame.width, end2: element.endFrame!.width, pos: -y_offset)
                }
                
                if element.startAlpha != nil && element.endAlpha != nil {
                    element.view.alpha = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: element.startAlpha!, end2: element.endAlpha!, pos: -y_offset)
                }
            }
            
            if self.headerColor != nil {
                let colorAlpha = self.linearTransform(start1: self.headerHeight, end1: self.minimumHeaderHeight, start2: self.colorStartAlpha, end2: self.colorEndAlpha, pos: -y_offset)
                self.headerBackgroundCover.backgroundColor = self.headerColor.withAlphaComponent(colorAlpha)
            }
            
        } else if y_offset > -self.minimumHeaderHeight {
            self.headerBackground.frame.size.height = self.minimumHeaderHeight
            
            for element in self.headerElements {
                
                if element.originalOffset != nil {
                    element.view.frame.origin.y = element.originalOffset! - (-self.minimumHeaderHeight + self.headerHeight)/element.upRatio!
                } else if element.endFrame != nil {
                    element.view.frame = element.endFrame!
                }
                
                if element.startAlpha != nil && element.endAlpha != nil {
                    element.view.alpha = element.endAlpha!
                }
            }
            
            if self.headerColor != nil {
                self.headerBackgroundCover.backgroundColor = self.headerColor.withAlphaComponent(self.colorEndAlpha)
            }
            
        }
        self.headerBackgroundCover.frame = self.headerBackground.frame
        for element in self.headerBackgroundElements {
            element.view.frame = self.headerBackground.frame
        }
    }
}
