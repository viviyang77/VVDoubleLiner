//
//  ViewController.m
//  VVDoubleLiner
//
//  Created by Vivi on 10/08/2017.
//  Copyright © 2017 Vivi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UILabel *resultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat x, y, w, h;
    x = 20;
    w = CGRectGetWidth(self.view.frame) - x * 2;
    y = 40;
    h = 50;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, w, h)];
    textField.placeholder = @"Type something here";
    textField.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    textField.delegate = self;
    textField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:textField];
    
    y = CGRectGetMaxY(textField.frame);
    h = 1;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    line.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:line];
    
    y = CGRectGetMaxY(line.frame) + x;
    h = CGRectGetHeight(self.view.frame) - CGRectGetMaxY(line.frame) - x * 2;
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    self.resultLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:20];
    self.resultLabel.adjustsFontSizeToFitWidth = YES;
    self.resultLabel.minimumScaleFactor = 11.0 / self.resultLabel.font.pointSize;
    self.resultLabel.numberOfLines = 2;
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.resultLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [self.view endEditing:YES];
    
    NSString *textInTwoLines = [self truncateStringToTwoLines:textField.text];
    self.resultLabel.text = textInTwoLines;
    
    return YES;
}

- (NSString *)truncateStringToTwoLines:(NSString *)inputString {
    
    if (inputString.length < 2) {
        return inputString;
    }
    
    NSMutableString *mutableString = [inputString mutableCopy];
    NSInteger indexToTruncate = inputString.length / 2;
    NSString *currentString = [inputString substringWithRange:NSMakeRange(indexToTruncate, 1)];
    NSString *previousString = [inputString substringWithRange:NSMakeRange(indexToTruncate - 1, 1)];
    
    NSArray *endingSymbols = @[@"/", @",", @".", @";", @":", @")", @"?", @"!", @"-", @"]", @">", @"}", @"_", @"+",
                               @"／", @"，", @"。", @"；", @"：", @"」", @"？", @"！", @"－", @"、"];
    
    if ([previousString isEqualToString:@" "] || [endingSymbols containsObject:previousString]) {
        
        // Directly add newline
        [mutableString insertString:@"\n" atIndex:indexToTruncate];
        return [mutableString copy];
    }
    
    if ([endingSymbols containsObject:currentString] || [currentString isEqualToString:@" "]) {
        
        // The current character is an ending symbol or space
        // Move to the next character until current character is NOT a space
        do {
            if (indexToTruncate + 1 >= inputString.length) {
                break;
            }
            indexToTruncate += 1;
            previousString = currentString;
            currentString = [inputString substringWithRange:NSMakeRange(indexToTruncate, 1)];
            
        } while ([currentString isEqualToString:@" "]);
        
        if (indexToTruncate == inputString.length - 1) {
            // If there is no space after the middle character, reset it back to length/2
            indexToTruncate = inputString.length / 2;
        }
        
        [mutableString insertString:@"\n" atIndex:indexToTruncate];
        return [mutableString copy];
    }
    
    NSArray *startingSymbols = @[@"(", @"<", @"[", @"{", @"$", @"#", @"「"];
    if ([startingSymbols containsObject:previousString]) {
        
        // The current character is a starting symbol
        indexToTruncate -= 1;
        currentString = previousString;
        if (indexToTruncate > 0) {
            previousString = [inputString substringWithRange:NSMakeRange(indexToTruncate - 1, 1)];
        } else {
            previousString = nil;
        }
        
        [mutableString insertString:@"\n" atIndex:indexToTruncate];
        return [mutableString copy];
    }
    
    if (![currentString canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
        // If the current character is not latin based
        [mutableString insertString:@"\n" atIndex:indexToTruncate];
        return [mutableString copy];
        
    } else {
        // The current character is latin based
        unichar currentChar = [inputString characterAtIndex:indexToTruncate];
        if ([[NSCharacterSet symbolCharacterSet] characterIsMember:currentChar] || [[NSCharacterSet punctuationCharacterSet] characterIsMember:currentChar] || [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:currentChar]) {
            
            // If the current string is a symbol / punctuation / number
            [mutableString insertString:@"\n" atIndex:indexToTruncate];
            return [mutableString copy];
        }
        
        // Look BACKWARDS for space or dash or non-latin character
        while (![previousString isEqualToString:@" "] && ![previousString isEqualToString:@"-"] && [previousString canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
            if (indexToTruncate - 1 < 0) {
                break;
            }
            
            indexToTruncate -= 1;
            currentString = previousString;
            
            if (indexToTruncate > 0) {
                previousString = [inputString substringWithRange:NSMakeRange(indexToTruncate - 1, 1)];
            } else {
                previousString = nil;
            }
        }
        
        if (indexToTruncate == 0) {
            
            // Try looking FORWARD for space or dash or non-latin character
            indexToTruncate = inputString.length / 2;
            currentString = [inputString substringWithRange:NSMakeRange(indexToTruncate, 1)];
            previousString = [inputString substringWithRange:NSMakeRange(indexToTruncate - 1, 1)];
            
            while (![previousString isEqualToString:@" "] && ![previousString isEqualToString:@"-"] && [previousString canBeConvertedToEncoding:NSISOLatin1StringEncoding]) {
                
                if (indexToTruncate + 1 >= inputString.length) {
                    break;
                }
                
                indexToTruncate += 1;
                previousString = currentString;
                currentString = [inputString substringWithRange:NSMakeRange(indexToTruncate, 1)];
            }
            
            if (indexToTruncate == inputString.length - 1) {
                indexToTruncate = inputString.length / 2;
                [mutableString insertString:@"-" atIndex:indexToTruncate];
                indexToTruncate += 1;
            }
        }
        
        [mutableString insertString:@"\n" atIndex:indexToTruncate];
        return [mutableString copy];
    }
}

@end
