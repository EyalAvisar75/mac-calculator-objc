//
//  ViewController.m
//  Calculator
//
//  Created by eyal avisar on 07/04/2020.
//  Copyright © 2020 eyal avisar. All rights reserved.
//
#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *screenLabel;
@property (weak, nonatomic) IBOutlet UIButton *ACButton;
@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) NSMutableArray *operations;
@property BOOL isACPressed;
@property BOOL isLastDigit;
@property BOOL isPlusMinus;
@property BOOL isProgression;
@property BOOL isPercentageProgression;
@end
//deal with 7+4X%= -> 7 + 0.16 * 4^1 %% 7+0.000256 * 4^2

@implementation ViewController

- (IBAction)handleDigit:(id)sender {
    if (!self.isLastDigit) {
        self.screenLabel.text = @"0";
    }
    self.isLastDigit = YES;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
    NSString *number = self.screenLabel.text;
    if([pressedText isEqual:@"+/-"]){
        self.isLastDigit = NO;
        double value = [number doubleValue];
        if(value != 0)
            value = value * -1;
        self.screenLabel.text = [NSString stringWithFormat:@"%40.15g",value];
        self.isPlusMinus = YES;
        return;
    }
    BOOL isDecimal = [number containsString:@"."];

    if(isDecimal && [pressedText isEqual:@"."])
        return;
    if([pressedText isEqual:@"."])
        number = [number stringByAppendingString:pressedText];
    else {
        if(!isDecimal){
            double value = [number doubleValue] * 10 + [pressedText doubleValue];
            number = [NSString stringWithFormat:@"%40.15g", value];
        }
        else
            number = [number stringByAppendingString:pressedText];
    }
    self.screenLabel.text = number;
    [self.ACButton setTitle:@"C" forState:UIControlStateNormal];
}

- (BOOL)calculateMultiplication:(NSArray *)numbers operation:(NSString *)operation {
    if([operation isEqual:@"X"]){
        self.screenLabel.text = [self multiply:numbers];
        return YES;
    }
    else if([operation isEqual:@"/"]){
        self.screenLabel.text = [self divide:numbers];
        return YES;
    }
    return NO;
}

- (BOOL)calculateAddition:(NSArray *)numbers operation:(NSString *)operation{
    if([operation isEqual:@"+"]){
        self.screenLabel.text = [self add:numbers];
        return YES;
    }
    else if([operation isEqual:@"-"]){
        self.screenLabel.text = [self subtract:numbers];
        return YES;
    }
    return NO;
}

- (BOOL)calculatePercentage:(UIButton *)pressed {//a+% a*a/100
    static NSMutableString *quotient;
    static NSMutableString *toSquare;
    if(![[pressed currentTitle] isEqual:@"%"]){
        if(quotient || toSquare){
            if(![self calculateMultiplication:@[quotient,self.screenLabel.text] operation:self.operations[0]]){
                [self calculateAddition:@[self.screenLabel.text, quotient] operation:self.operations[0]];
                [self.operations removeLastObject];
                [self.operations addObject:[pressed currentTitle]];
            }
            quotient = nil;
            toSquare = nil;
            self.isProgression = NO;
        }
        return NO;
    }
    if(self.operations.count == 1){
        [self calculateMultiplication:@[self.screenLabel.text, @"100"] operation:@"/"];
        [self.numbers removeLastObject];
    }
    else {
        self.isProgression = YES;
        if(toSquare && [toSquare isEqual:@"yes"]){
            if(quotient)
                quotient = self.screenLabel.text;
            self.numbers[0] = quotient;
            [self calculateMultiplication:@[self.screenLabel.text ,self.screenLabel.text] operation:@"X"];
            [self calculateMultiplication:@[self.screenLabel.text, @"100"] operation:@"/"];
            [self.numbers removeLastObject];
            [self.operations removeLastObject];
            return YES;
        }
        if(!quotient){
            quotient = self.numbers[0];
        }
        if(!toSquare){
            if (self.isLastDigit) {
                toSquare = @"no";
            } else {
                toSquare = @"yes";
            }
        }
        [self calculateMultiplication:@[quotient ,self.screenLabel.text] operation:@"X"];
        [self calculateMultiplication:@[self.screenLabel.text, @"100"] operation:@"/"];
    }
    [self.numbers removeLastObject];
    [self.operations removeLastObject];
    return YES;
}

- (IBAction)handleOperations:(id)sender {
    UIButton *pressed = (UIButton *)sender;
    if(self.isLastDigit || self.isPlusMinus ||
       [[pressed currentTitle] isEqual:@"="] ||
       [[pressed currentTitle] isEqual:@"%"]){
        [self.numbers addObject:self.screenLabel.text]; //save'em
        [self.operations addObject:[pressed currentTitle]];
        NSLog(@"nums %@ ops %@ pressed %@",self.numbers, self.operations, [[pressed currentTitle] description]);
        if([self calculatePercentage:pressed]){
            self.isLastDigit = NO;
            return;
        }
        self.isLastDigit = NO;
        if([self isAXB]){
            if(self.operations.count > 1 && [[self.operations lastObject] isEqual:@"="]){
                [self.operations removeLastObject];
                return;
            }
            return;
        }
        if([self isAdditionInTernaryExpression]){
            if(!self.isProgression){
                self.isLastDigit = NO;
            }
            return;
        }
        self.isLastDigit = NO;//last round was operation
        self.isPlusMinus = NO;//or this
        
    }
    if(self.isProgression){
        if([[self.operations lastObject] isEqual:@"="]){
            self.isProgression = NO;
            [self.operations removeAllObjects];
            [self.operations addObject:[pressed currentTitle]];
        }
        else
            [self calculatePercentage:pressed];
        self.isLastDigit = NO;
        [self.numbers removeAllObjects];
        [self.numbers addObject:self.screenLabel.text];
    }
        [self.operations removeLastObject];
        [self.operations addObject:[pressed currentTitle]];
        NSLog(@"end ops %@",self.operations);
        NSLog(@"end nums %@",self.numbers);
    
}

- (void)calculated1Numbers {//cleaning after simple running calculation
    [self.numbers removeAllObjects];
    if([[self.operations lastObject] isEqual:@"="]){
        [self.operations removeLastObject];
        return;
    }
    [self.operations removeObjectAtIndex:0];
    [self.numbers addObject:self.screenLabel.text];
}

- (void)calculateTerm1Unary {//aXb a/b
    if(self.operations.count == 1){
        if(![self calculateMultiplication:@[self.numbers[0],self.numbers[0]] operation:self.operations[0]]){
            [self calculateAddition:@[self.numbers[0],self.numbers[0]] operation:self.operations[0]];
        }
    }
}

- (BOOL)isAXB {//a*b*V a+a*b*V a*=V a*b=V a+b*= a+b*c=V
    static NSMutableString *quotient;//should know to terminate if ac? isReseted
    static NSMutableString *termN;
    if(self.isACPressed){
        quotient = nil;
        termN = nil;
        [self.operations addObject:@"terminateStatic"];
        [self isAdditionInTernaryExpression];
    }
    if(![self.operations containsObject:@"="]){
        self.isProgression = NO;
        termN = nil;
    }
    else if(!self.isProgression){
        self.isProgression = YES;
        quotient = [self.numbers lastObject];
    }

    if(!([self.operations containsObject:@"X"] ||
         [self.operations containsObject:@"/"])){
        return NO;
    }
    
    if(quotient && self.operations.count == 3 && self.isLastDigit){//a+b*c=
        [self calculateMultiplication:@[self.numbers[1],quotient]  operation:self.operations[1]];
        [self calculateAddition:@[self.screenLabel.text,self.numbers[0]] operation:self.operations[0]];
        [self.operations removeObjectAtIndex:0];
        termN = [[NSMutableString alloc]initWithString: self.screenLabel.text];
        self.isProgression = YES;
        return YES;
    }
    if(quotient && self.operations.count == 3){//a+b*=
        [self calculateMultiplication:@[self.numbers[0],quotient]  operation:self.operations[1]];
        [self calculateAddition:@[self.screenLabel.text,quotient] operation:self.operations[0]];
        [self.operations removeObjectAtIndex:0];
        [self.numbers removeAllObjects];
        termN = [[NSMutableString alloc]initWithString: self.screenLabel.text];
        self.isProgression = YES;
        return YES;
    }
    
    if(!quotient){
        for (int i = 0; i < self.operations.count - 1; i++) {
            if([self calculateMultiplication:@[self.numbers[i], self.numbers[i+1]] operation:self.operations[i]]){
                [self.operations removeObjectAtIndex:i];
                [self.numbers removeObjectAtIndex:i];
                self.numbers[i] = self.screenLabel.text;
                i--;
            }
        }
        self.isProgression = NO;
        return NO;
    }
    
    NSString *number = self.screenLabel.text;
    if(self.numbers.count == 2 && self.operations.count == 2){
        number = self.numbers[0];
        quotient = self.numbers[1];
    }
    //handle progression stop with * like a*===*b
    
//    a*= a*b= a+b*= a+b*c=
    
    NSArray *operands = (quotient)?@[number,quotient]:self.numbers;
    if([self.operations containsObject:@"="])
        self.isProgression = YES;
    if(self.operations.count == 2){//is aXb? return and exit
        if(operands.count == 2 && [self calculateMultiplication:operands operation:self.operations[0]]){
            [self calculated1Numbers];
            termN = [[NSMutableString alloc]initWithString: self.screenLabel.text];
            return YES;
        }
    }
    quotient = nil;
    self.isProgression = NO;
    return NO;
}

- (BOOL)isAdditionInTernaryExpression {//chain addition
    static NSString *difference;
    static NSMutableString *termN;
    if(self.isACPressed){
        difference = nil;
        termN = nil;
        self.isACPressed = NO;
        if([[self.operations lastObject] isEqual:@"terminateStatic"]){
            [self.operations removeLastObject];
            return NO;
        }
    }
    if(![[self.operations lastObject] isEqual:@"="]){
        self.isProgression = NO;
    }
    if (!self.isProgression && termN) {
        termN = nil;
    }
    if([self.operations containsObject:@"X"] ||
       [self.operations containsObject:@"/"]){
        return NO;
    }
    if (!difference) {
        difference = [self.numbers lastObject];
    }
    if(![self.operations containsObject:@"="]){
        difference = nil;
    }
    else {
        self.isProgression = YES;
    }

    NSArray *numbers;
    if(difference && self.numbers.count == 1){
        numbers = @[self.screenLabel.text, difference];
    }
    else if(self.numbers.count == 2){
        difference = self.numbers[1];
        numbers = self.numbers;
    }
    else {
        return NO;
    }
    if(self.operations.count >= 2){//self.operations.count == 2
        [self calculateAddition:numbers operation:self.operations[0]];
        [self calculated1Numbers];
        if(self.isProgression)
            termN = self.screenLabel.text;
        return YES;
    }
    return NO;
}

- (void)resetFields {
    self.numbers = [NSMutableArray new];
    self.operations =[NSMutableArray new];
    self.isLastDigit = NO;
    self.isPlusMinus = NO;
    self.isProgression = NO;
    self.isPercentageProgression = NO;
    self.screenLabel.text = @"0";
}

- (IBAction)handleAC:(id)sender {
    UIButton *pressed = (UIButton *) sender;
    NSString *pressedText = ((UIButton *)sender).titleLabel.text;
//    [self resetProgressionMode:pressed pressedText:pressedText];
    if([pressedText isEqualToString:@"AC"]){
        self.isACPressed = YES;
        [self resetFields];
    }
    else {
        [pressed setTitle:@"AC" forState:UIControlStateNormal];
        if(self.isLastDigit){
            self.screenLabel.text = @"0";
        }
        else {
            [self.operations removeLastObject];
        }
    }
}

- (void)viewDidLoad {
    [self resetFields];
}

-(NSString *)add:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] + [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)subtract:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] - [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)multiply:(NSArray *)numbers {
    double result = [numbers[0] doubleValue] * [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}
-(NSString *)divide:(NSArray *)numbers {
    if ([numbers[1] doubleValue] == 0) {
        return @"Not a number";
    }
    double result = [numbers[0] doubleValue] / [numbers[1] doubleValue];
    return [NSString stringWithFormat:@"%40.15g",result];
}

@end
