//
//  CustomsFlowLayouts.swift
//  MarksHot
//
//  Created by Quentin Beaudouin on 26/10/2016.
//  Copyright © 2016 Quentin Beaudouin. All rights reserved.
//

import UIKit

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        
        return attributes
    }
}



class CustomVerticalAppearingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    
    
    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        
        if let collectionRect = collectionView?.bounds {
            attr?.center = CGPoint(x:collectionRect.midX, y:collectionRect.maxY)
            attr?.alpha = 0
        }
        return attr
        
    }
    
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {

        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        
        if let collectionRect = collectionView?.bounds {
            attr?.center = CGPoint(x:collectionRect.midX, y:collectionRect.maxY)
            attr?.size = CGSize(width: collectionRect.size.width, height: itemSize.height)
            attr?.alpha = 0
        }
        return attr
    }
    
}

class CustomHorizontalAppearingCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    
    
    override open func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        
        if let collectionRect = collectionView?.bounds {
            attr?.center = CGPoint(x:collectionRect.minX, y:collectionRect.midY)
            attr?.alpha = 0
        }
        return attr
        
    }
    
    override open func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attr = self.layoutAttributesForItem(at: itemIndexPath)
        
        if let collectionRect = collectionView?.bounds {
            attr?.center = CGPoint(x:collectionRect.minX, y:collectionRect.midY)
            attr?.size = CGSize(width: itemSize.width, height: itemSize.height)
            attr?.alpha = 0
        }
        return attr
    }
    
}







