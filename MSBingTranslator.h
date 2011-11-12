/*
-- MSBingTranslator.h
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

#import <Foundation/Foundation.h>

#define bingAPI_translate @"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId="
#define bingAPI_detect @"http://api.microsofttranslator.com/v2/Http.svc/Detect?appId="
#define bingApp_ID @"App_API_ID_Here"       //get one at https://ssl.bing.com/webmaster/developers/appids.aspx
#define s1 s2

@protocol MSBingTranslatorDelegate;

@interface MSBingTranslator : NSObject
{
@public
    id<MSBingTranslatorDelegate> delegate;
    
@private
    NSMutableData *receivedData;
    NSURLConnection *translate_connection, *detect_connection;
}

@property(nonatomic, retain) id<MSBingTranslatorDelegate> delegate;
+ (MSBingTranslator *) sharedTranslator;
- (void) initWithDelegate:(id)del andTranslateText:(NSString *)text fromLan:(NSString *)txtLan toLan:(NSString *)localLan;
- (void) initWithDelegate:(id)del andDetectLanguageTypeForText:(NSString *)text;
@end


@protocol MSBingTranslatorDelegate <NSObject>
- (void) MSBingTranslator:(MSBingTranslator *)cls translatedText:(NSString *) text;
- (void) MSBingTranslator:(MSBingTranslator *)cls detectedLanguage:(NSString *)lan;
- (void) MSBingTranslator:(MSBingTranslator *)cls failedWithError:(NSString *) error;
@end