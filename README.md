Drop-In Class for Bing Translator

GET App_ID at https://ssl.bing.com/webmaster/developers/appids.aspx
Then change ID inside MSBingTranslator.h

How to use

```objc
Add MSBingTranslatorDelegate

[[MSBingTranslator sharedTranslator] initWithDelegate:self andTranslateText:@"hello" fromLan:nil toLan:@"ja"];
```

Read LICENSE


