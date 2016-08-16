//
//  CustomView.m
//  xiangDuiYueShu
//
//  Created by song on 15/2/4.
//  Copyright (c) 2015年 song. All rights reserved.
//

#import "CustomView.h"
#import <CoreText/CoreText.h>

@interface CustomView()
@property (nonatomic) CTFramesetterRef framesetter;
@property(nonatomic) NSMutableAttributedString *attributedString;
@end
@implementation CustomView
-(void)awakeFromNib{

    
_framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedString);

}
CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName,
                                            font.pointSize,
                                            NULL);
    return ctFont;
}



- (NSAttributedString *)attributedString
{
      NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"bbb刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩刘文倩"];
      _attributedString = string;
    
    NSRange remainingRange = NSMakeRange(0, [string length]);
    [string addAttribute:(id)kCTForegroundColorAttributeName value:(id)[UIColor redColor].CGColor range:remainingRange];
    
    
    
    NSNumber *underline = [NSNumber numberWithInt:kCTUnderlineStyleSingle];
    [string addAttribute:(id)kCTUnderlineStyleAttributeName
                              value:(id)underline
                              range:NSMakeRange(5, 5)];
    UIFont *font=[UIFont systemFontOfSize:20];
    CTFontRef ctFont = CTFontCreateFromUIFont(font);
    //字体
    [string addAttribute:(id)kCTFontAttributeName
                              value:(__bridge id)ctFont
                              range:remainingRange];
    CFRelease(ctFont);
    //加点段落间距
    float paragraphLeading=0;
   // float par=0;
    CTParagraphStyleSetting settings[]={
   // {kCTParagraphStyleSpecifierTailIndent, sizeof(CGFloat), &par},
    {kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &paragraphLeading},
    
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 1);
    [string addAttribute:(id)kCTParagraphStyleAttributeName
                              value:(__bridge id)paragraphStyle
                              range:remainingRange];
    CFRelease(paragraphStyle);
    
    return _attributedString;
}


void RunDelegateDeallocCallback( void* refCon ){
    
}

CGFloat RunDelegateGetAscentCallback( void *refCon ){
    return  0;
   }

CGFloat RunDelegateGetDescentCallback(void *refCon){
    NSString *imageName = (__bridge NSString *)refCon;
    return [UIImage imageNamed:imageName].size.height;

}

CGFloat RunDelegateGetWidthCallback(void *refCon){
    NSString *imageName = (__bridge NSString *)refCon;
    return [UIImage imageNamed:imageName].size.width;
}



-(void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);//设置字形变换矩阵为CGAffineTransformIdentity，也就是说每一个字形都不做图形变换
//    
//    CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,self.bounds.size.height);
//    CGContextConcatCTM(context, flipVertical);//将当前context的坐标系进行flip

    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"测试富文本显测试富文本显测试富文本显测试富文本显测试富文本显测试富文本显"] ;
    
    //为所有文本设置字体
    //[attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:24] range:NSMakeRange(0, [attributedString length])]; // 6.0+
    UIFont *font = [UIFont systemFontOfSize:24];
    CTFontRef fontRef = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:NSMakeRange(0, [attributedString length])];
    
    
    //为图片设置CTRunDelegate,delegate决定留给图片的空间大小
    NSString *taobaoImageName = @"taobao.png";
    CTRunDelegateCallbacks imageCallbacks;
    imageCallbacks.version = kCTRunDelegateVersion1;
    imageCallbacks.dealloc = RunDelegateDeallocCallback;
    imageCallbacks.getAscent = RunDelegateGetAscentCallback;
    imageCallbacks.getDescent = RunDelegateGetDescentCallback;
    imageCallbacks.getWidth = RunDelegateGetWidthCallback;
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)(taobaoImageName));
    NSMutableAttributedString *imageAttributedString = [[NSMutableAttributedString alloc] initWithString:@" "];//空格用于给图片留位置
    [imageAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(0, 1)];
    CFRelease(runDelegate);
    
    [imageAttributedString addAttribute:@"imageName" value:taobaoImageName range:NSMakeRange(0, 1)];
    
    [attributedString insertAttributedString:imageAttributedString atIndex:1];
    
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)attributedString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0.0, 0.0, self.bounds.size.width, self.bounds.size.height);
    CGPathAddRect(path, NULL, bounds);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter,CFRangeMake(0, 0), path, NULL);
    CTFrameDraw(ctFrame, context);
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    CGPoint lineOrigins[CFArrayGetCount(lines)];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    for (int i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        for (int j = 0; j < CFArrayGetCount(runs); j++) {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[i];
            lineOrigin.y=self.bounds.size.height-lineOrigin.y;
            
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, j);
            NSDictionary* attributes = (NSDictionary*)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0,0), &runAscent, &runDescent, NULL);
            
            runRect=CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y -runAscent, runRect.size.width, runAscent + runDescent);
            
            NSString *imageName = [attributes objectForKey:@"imageName"];
            //图片渲染逻辑
            if (imageName) {
                UIImage *image = [UIImage imageNamed:imageName];
                if (image) {
                    
                   // CGContextSetTextMatrix(context, CGAffineTransformIdentity);
                    CGContextTranslateCTM(context, 0, self.bounds.size.height);
                    CGContextScaleCTM(context, 1.0, -1.0);

                    
                    CGRect imageDrawRect;
                    imageDrawRect.size = image.size;
                    imageDrawRect.origin.x = runRect.origin.x ;
                    imageDrawRect.origin.y = runRect.origin.y;
                 //   CGContextDrawImage(context, imageDrawRect, image.CGImage);
                   [image drawInRect:imageDrawRect];
                }
            }
        }
    }
    
    CFRelease(ctFrame);
    CFRelease(path);
    CFRelease(ctFramesetter);

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    //[super drawRect:rect];
//    [[UIColor greenColor] set];
//    CGContextRef context=UIGraphicsGetCurrentContext();
//    
//    
//   
//    
//     CGMutablePathRef mainPath=CGPathCreateMutable();
//    // CGPathAddRect(mainPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
////       CGPathRef path1=CGPathCreateWithRect(CGRectMake(20, self.bounds.size.height-25, self.bounds.size.width-20, 25),NULL);
////     CGPathAddPath(mainPath, NULL, path1);
//    CGPathRef path2=CGPathCreateWithRect(CGRectMake(0,0, self.bounds.size.width, self.bounds.size.height-25),NULL);
//    CGPathAddPath(mainPath, NULL, path2);
////
////    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
////    CGContextTranslateCTM(context, 0, self.bounds.size.height);
////    CGContextScaleCTM(context, 1.0, -1.0);
//
//  //  CGPathAddRect(mainPath, NULL, CGRectMake(0, -110, self.bounds.size.width, self.bounds.size.height-110));
//      //CGPathAddRect(mainPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
//    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//    CGContextTranslateCTM(context, 0, self.bounds.size.height);
//    CGContextScaleCTM(context, 1.0, -1);
//
//    
//    CTFrameRef drawFrame = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
//    
//    
//    
//    CTFrameDraw(drawFrame, context);
//     //看看行信息
//    
//   NSArray *lines=(__bridge NSArray *) CTFrameGetLines(drawFrame);
//    NSInteger lineCount=[lines count];
//    CGPoint origins[lineCount];
//    
//    CTFrameGetLineOrigins(drawFrame, CFRangeMake(0, 0), origins);
//    for(int i=0;i<lineCount;i++){
//        NSLog(@"x=%f,y=%f\n",origins[i].x,origins[i].y);
//        CGPoint baselineOrigin = origins[i];
//        //int height=CGRectGetHeight(self.frame);
//         baselineOrigin.y = CGRectGetHeight(self.frame) - baselineOrigin.y;
//         CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
//        
//        
//        
//        CGFloat ascent, descent;
//        
//        CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
//        NSLog(@"ascent=%f,descent=%f\n",ascent,descent);
//        
//        CGRect lineFrame = CGRectMake(baselineOrigin.x, baselineOrigin.y - ascent, lineWidth, ascent + descent);
//        
//        CFRange lineRange= CTLineGetStringRange(line);
//        
//        
//        
//        CFArrayRef runs = CTLineGetGlyphRuns(line);//获取line中包含所有run的数组,我的理解是返回几种属性类型，通过applyStyle方法添加进去的
//        
//        for(CFIndex j=0;j<CFArrayGetCount(runs);j++)
//        {
//            CTRunRef run=CFArrayGetValueAtIndex(runs, j);
//            NSDictionary *attributes=(__bridge NSDictionary*)CTRunGetAttributes(run);
//            
//            
//            
//            CGRect runBounds;
//            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, NULL); //8
//            runBounds.size.height = ascent + descent;
//
//            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL); //9
//            runBounds.origin.x = baselineOrigin.x + self.frame.origin.x + xOffset;
//            runBounds.origin.y = baselineOrigin.y + lineFrame.size.height;
//
//            
//        }
//        
//        
//        
//        int ii=0;
//    }
//    
//    
//    
//    
//    CFRelease(drawFrame);
//    CGPathRelease(mainPath);
//   
//   // [self getLineRectFromNSRange:NSMakeRange(0, 1)];



}
//得到包含range的那一行的Rect
- (CGRect)getLineRectFromNSRange:(NSRange)range
{
    CGMutablePathRef mainPath = CGPathCreateMutable();
   
        CGPathAddRect(mainPath, NULL, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
        
    CTFrameRef ctframe = CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), mainPath, NULL);
    CGPathRelease(mainPath);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(ctframe);
    NSInteger lineCount = [lines count];
    CGPoint origins[lineCount];
    if (lineCount != 0)
    {
        for (int i = 0; i < lineCount; i++)
        {
            CTLineRef line = (__bridge CTLineRef)[lines objectAtIndex:i];
            CFRange lineRange= CTLineGetStringRange(line);
            if (range.location >= lineRange.location && (range.location + range.length)<= lineRange.location+lineRange.length)
            {
                CTFrameGetLineOrigins(ctframe, CFRangeMake(0, 0), origins);
                CGPoint origin = origins[i];
                CGFloat ascent,descent,leading;
                CGFloat lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
                origin.y = self.frame.size.height-(origin.y);
                CFRelease(ctframe);
                CGRect lineRect = CGRectMake(origin.x, origin.y+descent-(ascent+descent+1), lineWidth, ascent+descent+1);
                return lineRect;
            }
        }
    }
    CFRelease(ctframe);
    return CGRectMake(-1, -1, -1, -1);
}


@end
