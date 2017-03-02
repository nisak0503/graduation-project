//
//  main.m
//  Hello World
//
//  Created by grace xia on 17/2/11.
//  Copyright (c) 2017年 Grace Alias . All rights reserved.
//

#import <Foundation/Foundation.h>
/*
int main(int argc, const char * argv[]) {
    
    NSLog(@"Hello, World!");
    return 0;
}
*/

BOOL AreIntDifferent (int thing1, int thing2)
{
    if (thing1 == thing2)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

NSString *boolString(BOOL yesNo)
{
    if (yesNo == NO)
    {
        return @"NO";
    }
    else
    {
        return @"YES";
    }
}

int main(int argc, const char *argv[])
{
    BOOL areTheyDifferent;
    areTheyDifferent = AreIntDifferent(5, 5);
    NSLog(@"are %d and %d different? %@", 5, 5, boolString(areTheyDifferent));
    areTheyDifferent = AreIntDifferent(25, 45);
    NSLog(@"are %d and %d different? %@", 25, 45, boolString(areTheyDifferent));
    return 0;
}

