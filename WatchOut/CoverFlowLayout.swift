//
//  CoverFloowLayout.swift
//  CoverFlowLayoutDemo
//
//  Created by Quentin Beaudouin on 12/01/2017.
//  Copyright © 2017 solomidSF. All rights reserved.
//

import UIKit

class CoverFlowLayout: UICollectionViewFlowLayout {
    
    
    static let kDistanceToProjectionPlane:CGFloat = 500.0
    
    /**
     *  Max degree that can be applied to individual item.
     *  Default to 45 degrees.
     */
    @IBInspectable var maxCoverDegree:CGFloat = 45
    
    /**
     *  Determines how elements covers each other.
     *  Should be in range 0..1.
     *  Default to 0.25.
     *  Examples:
     *  0 means that items are placed within a continuous line.
     *  0.5 means that half of 3rd and 1st item will be behind 2nd.
     */
    @IBInspectable var coverDensity:CGFloat = 0.25
    
    /**
     *  Min opacity that can be applied to individual item.
     *  Default to 1.0 (alpha 100%).
     */
    @IBInspectable var minCoverOpacity:CGFloat = 1.0
    
    /**
     *  Min scale that can be applied to individual item.
     *  Default to 1.0 (no scale).
     */
    @IBInspectable var minCoverScale:CGFloat = 1.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
    }
    
    override func prepare() {
        super.prepare()
        assert(self.collectionView?.numberOfSections == 1, "[YRCoverFlowLayout]: Multiple sections aren't supported!")
        assert(self.scrollDirection == .horizontal, "[YRCoverFlowLayout]: Vertical scrolling isn't supported!")
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let idxPaths = indexPath(in: rect)
        
        var resultingAttributes = [UICollectionViewLayoutAttributes]()

        for path in idxPaths {
            // We should create attributes by ourselves.
            if let attributes = layoutAttributesForItem(at: path) {
                resultingAttributes.append(attributes)
            }
            
        }
        
        return resultingAttributes
        
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if collectionView == nil { return nil }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        attributes.size = self.itemSize;
        attributes.center = CGPoint(x: collectionViewWidth * CGFloat(indexPath.row) + collectionViewWidth,
                                    y: collectionViewHeight / 2)

        interpolate(attributes: attributes, offset: collectionView!.contentOffset.x)
        
        
        return attributes;
    }
    
    override var collectionViewContentSize: CGSize {
        
        if let colView = collectionView {
            return CGSize(width: colView.bounds.size.width * CGFloat(colView.numberOfItems(inSection: 0)), height: colView.bounds.size.height)
        }
        return CGSize.zero
        
    }
    
    // MARK: - Accessors
    
    var collectionViewWidth:CGFloat! {
        return self.collectionView?.bounds.size.width ?? 0
    }
    
    var collectionViewHeight:CGFloat! {
        return self.collectionView?.bounds.size.height ?? 0
    }
    
    
}

//************************************
// MARK: - Private
//************************************

extension CoverFlowLayout {
    
    fileprivate func itemCenter(for row:Int) -> CGPoint {
        
        if let collectionViewSize = self.collectionView?.bounds.size {
            return CGPoint(x: CGFloat(row) * collectionViewSize.width + collectionViewSize.width / 2,
                           y: collectionViewSize.height / 2)
            
        }
        
        return CGPoint.zero
        
    }
    
    fileprivate func minX(for row:Int) -> CGFloat {
        return self.itemCenter(for: row - 1).x + (1/2 - coverDensity) * self.itemSize.width

    }
    
    fileprivate func maxX(for row:Int) -> CGFloat {
        return self.itemCenter(for: row - 1).x - (1/2 - coverDensity) * self.itemSize.width
    }
    
    fileprivate func minXCenter(for row:Int) -> CGFloat {
        let halfWidth = self.itemSize.width / 2
        let maxRads = degreesToRad(maxCoverDegree)
        let center = itemCenter(for: row - 1).x
        let prevItemRightEdge = center + halfWidth
        let projectedLeftEdgeLocal:CGFloat = halfWidth * CGFloat(cos(maxRads)) * CoverFlowLayout.kDistanceToProjectionPlane / (CoverFlowLayout.kDistanceToProjectionPlane + halfWidth * CGFloat(sin(maxRads)))
        
        return prevItemRightEdge - self.coverDensity * self.itemSize.width + projectedLeftEdgeLocal;
    }
    
    fileprivate func maxXCenter(for row:Int) -> CGFloat {
        let halfWidth = self.itemSize.width / 2
        let maxRads = degreesToRad(maxCoverDegree)
        let center = itemCenter(for: row + 1).x
        let nextItemLeftEdge = center - halfWidth
        let projectedRightEdgeLocal = abs(halfWidth * cos(maxRads) * CoverFlowLayout.kDistanceToProjectionPlane / (-halfWidth * sin(maxRads) - CoverFlowLayout.kDistanceToProjectionPlane))
        
        return nextItemLeftEdge + self.coverDensity * self.itemSize.width - projectedRightEdgeLocal;
    }
    
    fileprivate func degreesToRad(_ degrees:CGFloat) -> CGFloat {
        return degrees * CGFloat.pi / 180
    }
    
    fileprivate func indexPath(in rect:CGRect) -> [IndexPath] {
        
        if collectionView == nil {
            return []
        }
        
        if collectionView!.numberOfItems(inSection: 0) == 0 {
            return []
        }
        
        
        // Find min and max rows that can be determined for sure.
        var minRow = Int(max(rect.origin.x / self.collectionViewWidth!, 0))
        var maxRow = Int(rect.maxX / self.collectionViewHeight!)
        
        // Additional check for rows that also can be included (our rows are moving depending on content size).
        let candidateMinRow = max(minRow - 1, 0)
        if maxX(for: candidateMinRow) >= rect.origin.x {
            minRow = candidateMinRow
        }
        
        let candidateMaxRow = min(maxRow + 1, collectionView!.numberOfItems(inSection: 0) - 1)
        if minX(for: candidateMaxRow) <= rect.maxX {
            maxRow = candidateMaxRow
        }

        
        // Simply add index paths between min and max.
        var resultingIdxPaths = [IndexPath]()
        
        for i in minRow ... maxRow {
            resultingIdxPaths.append(IndexPath(item: i, section: 0))
        }
        
        
        return resultingIdxPaths
    }
    
    fileprivate func interpolate(attributes:UICollectionViewLayoutAttributes, offset:CGFloat) {
        
        let attributesPath = attributes.indexPath
        
        // Interpolate offset for given attribute. For this task we need min max interval and min and max x allowed for item.
        let minInterval:CGFloat = CGFloat(attributesPath.row - 1) * self.collectionViewWidth
        let maxInterval:CGFloat = CGFloat(attributesPath.row + 1) * self.collectionViewWidth
        
        let minX:CGFloat = minXCenter(for: attributesPath.row)
        let maxX:CGFloat = maxXCenter(for: attributesPath.row)
        let spanX:CGFloat = maxX - minX
        
        // Interpolate by formula
        let interpolatedX = min(max(minX + ((spanX / (maxInterval - minInterval)) * (offset - minInterval)),
                                        minX),
                                    maxX);
        attributes.center = CGPoint(x: interpolatedX, y: attributes.center.y)
        
        
        var transform = CATransform3DIdentity
        // Add perspective.
        transform.m34 = -1.0 / CoverFlowLayout.kDistanceToProjectionPlane;
        
        // Then rotate.
        let angle = -self.maxCoverDegree + (interpolatedX - minX) * 2 * self.maxCoverDegree / spanX;
        transform = CATransform3DRotate(transform, angle * CGFloat.pi / 180, 0, 1, 0);
        
        // Then scale: 1 - abs(1 - Q - 2 * x * (1 - Q))
        let scale = 1.0 - abs(1.0 - self.minCoverScale - (interpolatedX - minX) * 2 * (1.0 - self.minCoverScale) / spanX);
        transform = CATransform3DScale(transform, scale, scale, scale);
        
        // Apply transform.
        attributes.transform3D = transform;
        
        // Add opacity: 1 - abs(1 - Q - 2 * x * (1 - Q))
        let opacity = 1.0 - abs(1.0 - self.minCoverOpacity - (interpolatedX - minX) * 2 * (1.0 - self.minCoverOpacity) / spanX);
        attributes.alpha = opacity;
    }
    
    
}












