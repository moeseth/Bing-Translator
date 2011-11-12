/*
-- MSBingTranslator.m
Copyright (c) 2011, moeseth All rights reserved.
 
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
 
- Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.
 
- Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
email : moeseth@me.com
*/

#import "MSBingTranslator.h"

static MSBingTranslator *translator = nil;

@implementation MSBingTranslator
@synthesize delegate;

+ (MSBingTranslator *) sharedTranslator
{
    if (translator == nil)
    {
        translator = [[self alloc] init];
    }
    return translator;
}

- (void) initWithDelegate:(id)del andTranslateText:(NSString *)text fromLan:(NSString *)txtLan toLan:(NSString *)localLan
{
    if (text.length < 1) return;
    
    self.delegate = del;
    receivedData = [[NSMutableData alloc] init];

    NSString *encodedString = [text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *string_prefix = bingAPI_translate bingApp_ID @"&text=";
    
    NSString *string_suffix = @"";
    
    if (txtLan.length > 1)
        string_suffix = [NSString stringWithFormat:@"&from=%@&to=%@",txtLan, localLan];
    else
        string_suffix = [NSString stringWithFormat:@"&to=%@", localLan];

    NSString *finalString = [NSString stringWithFormat:@"%@%@%@", string_prefix, encodedString, string_suffix];
    NSURL *queryURL = [NSURL URLWithString:finalString];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    translate_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) initWithDelegate:(id)del andDetectLanguageTypeForText:(NSString *)text
{
    if (text.length < 1) return;

    self.delegate = del;

    receivedData = [[NSMutableData alloc] init];

    NSString *encodedString = [text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *string_prefix = bingAPI_detect bingApp_ID @"&text=";
    NSString *finalString = [string_prefix stringByAppendingString:encodedString];
    NSURL *queryURL = [NSURL URLWithString:finalString];
    NSURLRequest *request = [NSURLRequest requestWithURL:queryURL];
    detect_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark -

- (void) connection: (NSURLConnection*) connection didReceiveData: (NSData*) data
{
    [receivedData appendData:data];
}

- (void) connection:(NSURLConnection*)connection didFailWithError:(NSError*) error
{
    NSLog(@"Translator Fail : %@", [error localizedDescription]);

    if ([delegate respondsToSelector:@selector(MSBingTranslator:failedWithError:)])
        [delegate MSBingTranslator:self translatedText:[error localizedDescription]];
    
    if (connection == translate_connection)
    {
        [translate_connection release];
        translate_connection = nil;
    } else {
        [detect_connection release];
        detect_connection = nil;
    }
    
    [receivedData release];
    receivedData = nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection*)connection
{
    NSString *received_txt = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];    
    
    [receivedData release];
    receivedData = nil;
    
    if (connection == translate_connection)
    {
        [translate_connection release];
        translate_connection = nil;
    } else 
    {
        [detect_connection release];
        detect_connection = nil;
    }
    
    if (received_txt != nil)
    {           
        NSArray *parts = [received_txt componentsSeparatedByString:@"/Serialization/\">"];
        if (parts.count < 1)
        {
            if ([delegate respondsToSelector:@selector(MSBingTranslator:failedWithError:)])
                [delegate MSBingTranslator:self failedWithError:@"not a valid language"];
            return;
        }
        
        NSString *toReturn = [parts objectAtIndex:1];
        toReturn = [toReturn stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
        
        if (connection == translate_connection)
        {
            if ([delegate respondsToSelector:@selector(MSBingTranslator:translatedText:)])
                [delegate MSBingTranslator:self translatedText:toReturn];
        } else 
        {
            if ([delegate respondsToSelector:@selector(MSBingTranslator:detectedLanguage:)])
                [delegate MSBingTranslator:self detectedLanguage:toReturn];
        }
    }
}

@end











