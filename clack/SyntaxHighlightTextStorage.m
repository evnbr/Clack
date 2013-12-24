//
//  SyntaxHighlightTextStorage.m
//  clack
//
//  Created by Evan Brooks on 12/17/13.
//  Copyright (c) 2013 Evan Brooks. All rights reserved.
//
// indebted to countless stackoverflow questions and http://www.raywenderlich.com/50151/text-kit-tutorial
//
//

#import "SyntaxHighlightTextStorage.h"
#import "ImageAttachment.h"

@implementation SyntaxHighlightTextStorage
{
    NSMutableAttributedString *_backingStore;
    NSDictionary *_replacements;
    CGFloat _fontSize;
    NSMutableParagraphStyle *_bodyParagraphStyle;
    NSMutableParagraphStyle *_fullBleedParagraphStyle;
}

- (id)init
{
    if (self = [super init]) {
        _backingStore = [NSMutableAttributedString new];
        
        _bodyParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        _bodyParagraphStyle.  firstLineHeadIndent = 20.0;
        _bodyParagraphStyle.headIndent = 20.0;
        _bodyParagraphStyle.tailIndent = -20.0;
        _bodyParagraphStyle.minimumLineHeight = 25.0;

        _fullBleedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        _fullBleedParagraphStyle.paragraphSpacing = 25.0;
        _fullBleedParagraphStyle.paragraphSpacingBefore = 25.0;
        
        _fontSize = 20.0;
        
        [self createHighlightPatterns];
    }
    return self;
}


- (NSString *)string {
    return [_backingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location
                     effectiveRange:(NSRangePointer)range
{
    return [_backingStore attributesAtIndex:location
                             effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    // NSLog(@"replaceCharactersInRange:%@ withString:%@", NSStringFromRange(range), str);
    
    [self beginEditing];
    [_backingStore replaceCharactersInRange:range withString:str];
    [self  edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes
            range:range
   changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range {
    // NSLog(@"setAttributes:%@ range:%@", attrs, NSStringFromRange(range));
    
    [self beginEditing];
    [_backingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

-(void)processEditing {
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_backingStore string]
                                                        lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_backingStore string]
                                                lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyStylesToRange:extendedRange];
}

- (void)applyStylesToRange:(NSRange)searchRange {
    NSDictionary* normalAttrs = @{NSFontAttributeName : [UIFont systemFontOfSize:_fontSize]};
    
    // iterate over each replacement
    for (NSString* key in _replacements) {
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:key
                                      options:0
                                      error:nil];
        
        NSDictionary* attributes = _replacements[key];
        
        [regex enumerateMatchesInString:[_backingStore string]
                                options:0
                                  range:searchRange
                             usingBlock:^(NSTextCheckingResult *match,
                                          NSMatchingFlags flags,
                                          BOOL *stop){
                                 // apply the style
                                 NSRange matchRange = [match rangeAtIndex:1];
                                 [self addAttributes:attributes range:matchRange];
                                 
                                 // reset the style to the original
                                 if (NSMaxRange(matchRange)+1 < self.length) {
                                     [self addAttributes:normalAttrs
                                                   range:NSMakeRange(NSMaxRange(matchRange)+1, 1)];
                                 }
                             }];
    }
}

- (void) createHighlightPatterns {
//    UIFontDescriptor *scriptFontDescriptor =
//    [UIFontDescriptor fontDescriptorWithFontAttributes:
//     @{UIFontDescriptorFamilyAttribute: @"Zapfino"}];
    
    // 1. base our script font on the preferred body font size
//    UIFontDescriptor* bodyFontDescriptor = [UIFontDescriptor
//                                            preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    //NSNumber* bodyFontSize = bodyFontDescriptor.
    //fontAttributes[UIFontDescriptorSizeAttribute];
    //UIFont* scriptFont = [UIFont fontWithDescriptor:scriptFontDescriptor size:[bodyFontSize floatValue]];
    
    // 2. create the attributes
    NSDictionary* boldAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:_fontSize]};
    NSDictionary* italicAttributes = @{NSFontAttributeName : [UIFont italicSystemFontOfSize:_fontSize]};
    NSDictionary* h1Attributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:_fontSize]};
    NSDictionary* numberingAttributes = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:_fontSize]};

    NSDictionary* imgAttributes = @{NSParagraphStyleAttributeName : _fullBleedParagraphStyle};
    
//    NSDictionary* boldAttributes = [self
//                                    createAttributesForFontStyle:UIFontTextStyleBody
//                                    withTrait:UIFontDescriptorTraitBold];
//    NSDictionary* italicAttributes = [self
//                                      createAttributesForFontStyle:UIFontTextStyleBody
//                                      withTrait:UIFontDescriptorTraitItalic];
    NSDictionary* strikeThroughAttributes = @{ NSStrikethroughStyleAttributeName : @1};
    // NSDictionary* scriptAttributes = @{ NSFontAttributeName : scriptFont};
    //NSDictionary* redTextAttributes =
    //@{ NSForegroundColorAttributeName : [UIColor redColor]};
    
    // construct a dictionary of replacements based on regexes
    _replacements = @{
                      // Match "*" + word + any number of spaces then words + "*" + space
                      @"\\*(\\w+(\\s\\w+)*)\\*\\s" : boldAttributes,
                      
                      // Match "_" + word + any number of spaces then words + "_" + space
                      @"(_\\w+(\\s\\w+)*_)\\s" : italicAttributes,
                      
                      // Match a number + "." + space (numbered list)
                      @"(?m)(^[0-9]+\\.)\\s" : numberingAttributes,
                      
                      // Match "-" + word + any number of spaces then words + "-" + space
                      @"(-\\w+(\\s\\w+)*-)\\s" : strikeThroughAttributes,
                      
                      // Match a # at line beginning + any number of characters + line end
                      @"(?m)^##*\\s*((.)*)[\\n\\r]" : h1Attributes,
                      //@"(~\\w+(\\s\\w+)*~)\\s" : scriptAttributes,
                      //@"\\s([A-Z]{2,})\\s" : redTextAttributes
                      
                      // Match a mysterious ImageAttatchment character, aka 0xfffc
                      @"(\ufffc)" : imgAttributes
                    };
}

- (NSDictionary*)createAttributesForFontStyle:(NSString*)style
                                    withTrait:(uint32_t)trait {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor
                                        preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    
    UIFontDescriptor *descriptorWithTrait = [fontDescriptor
                                             fontDescriptorWithSymbolicTraits:trait];
    
    UIFont* font =  [UIFont fontWithDescriptor:descriptorWithTrait size: 0.0];
    return @{ NSFontAttributeName : font };
}

-(void)update {
    // update the highlight patterns
    [self createHighlightPatterns];
    
    // change the 'global' font
    NSDictionary* bodyFont = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:_fontSize],
                               NSParagraphStyleAttributeName : _bodyParagraphStyle };
    [self addAttributes:bodyFont
                  range:NSMakeRange(0, self.length)];
    
    // NSLog(@"updating everything to original body font");
    
    // re-apply the regex matches
    [self applyStylesToRange:NSMakeRange(0, self.length)];
}


@end
