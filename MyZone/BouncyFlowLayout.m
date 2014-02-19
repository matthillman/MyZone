//
//  BouncyFlowLayout.m
//  UICollectionViewTest
//
//  Created by Matthew Hillman on 2/10/14.
//  Copyright (c) 2014 Matthew Hillman. All rights reserved.
//

#import "BouncyFlowLayout.h"

#define SCROLL_RESISTANCE 1500.0f

@interface BouncyFlowLayout ()
@property (strong, nonatomic) UIDynamicAnimator *animator;

@property (strong, nonatomic) NSMutableSet *visibleIndexPaths;
@property (assign, nonatomic) CGFloat latestDelta;
@end

@implementation BouncyFlowLayout

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (!(self = [super initWithCoder:aDecoder])) return nil;

    [self setup];
    
    return self;
}
- (id)init
{
    if (!(self = [super init])) return nil;
    
    [self setup];
    
    return self;
}

- (void)setup
{
    self.animator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    self.visibleIndexPaths = [NSMutableSet set];
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, -100, -100);
    NSArray *itemsInVisibleRect = [super layoutAttributesForElementsInRect:visibleRect];
    NSSet *indexPathsInVisibleRect = [NSSet setWithArray:[itemsInVisibleRect valueForKey:@"indexPath"]];
    
    NSArray *noLongerVisible = [self.animator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        return [indexPathsInVisibleRect member:[[[behaviour items] lastObject] indexPath]] == nil;
    }]];
    
    [noLongerVisible enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.animator removeBehavior:obj];
        [self.visibleIndexPaths removeObject:[[[obj items] lastObject] indexPath]];
    }];
    
    NSArray *newlyVisible = [itemsInVisibleRect filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        return [self.visibleIndexPaths member:item.indexPath] == nil;
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisible enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehaviour.length = 0.0f;
        springBehaviour.damping = 0.8f;
        springBehaviour.frequency = 1.0f;
        
        if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
            CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
            CGFloat scrollResistance = distanceFromTouch / SCROLL_RESISTANCE;
            
            if (self.latestDelta < 0) {
                center.y += MAX(self.latestDelta, self.latestDelta*scrollResistance);
            }
            else {
                center.y += MIN(self.latestDelta, self.latestDelta*scrollResistance);
            }
            item.center = center;
        }
        
        [self.animator addBehavior:springBehaviour];
        [self.visibleIndexPaths addObject:item.indexPath];
    }];
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.animator itemsInRect:rect];
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.animator layoutAttributesForCellAtIndexPath:indexPath];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    UIScrollView *scrollView = self.collectionView;
    CGFloat delta = newBounds.origin.y - scrollView.bounds.origin.y;
    
    self.latestDelta = delta;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.animator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat distanceFromTouch = fabsf(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / SCROLL_RESISTANCE;
        
        UICollectionViewLayoutAttributes *item = [springBehaviour.items firstObject];
        CGPoint center = item.center;
        if (delta < 0) {
            center.y += MAX(delta, delta*scrollResistance);
        }
        else {
            center.y += MIN(delta, delta*scrollResistance);
        }
        item.center = center;
        
        [self.animator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
