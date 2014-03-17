# MMLayerAccessibility
[![Build Status](https://travis-ci.org/mmllr/MMLayerAccessibility.png?branch=master)](https://travis-ci.org/mmllr/MMLayerAccessibility)

Sometimes you need to build a user interface in a custom view from CoreAnimation layers. Unfortunately they don't support NSAccessibility and renders the UI useless for your disabled users.

So I developed a solution which adds NSAccessibility support to CALayer and all its subclasses (via a category) and provides an easy to use, block based API:

```objective-c
-(void)setReadableAccessibilityAttribute:(NSString*)attribute withBlock:(id(^)(void))handler;

	CATextLayer *layer...
	__weak CATextLayer *weakLayer = layer;

	[layer setReadableAccessibilityAttribute:NSAccessibilityTitleAttribute
							   withBlock:^id{
									CATextLayer *strongLayer = weakLayer;
									return strongLayer.string;
									}];
```
With this method you set an accessibility attribute to a CALayer, the handler block must return a value specific for the attribute (such as a NSString, NSValue, NSArray...see the [NSAccessibility Documentation](https://developer.apple.com/librarY/mac/documentation/Cocoa/Conceptual/Accessibility/cocoaAXIntro/cocoaAXintro.html) on Apples developer website.

```objective-c
-(void)setWritableAccessibilityAttribute:(NSString*)attribute readBlock:(id(^)(void))getter writeBlock:(void(^)(id value))setter;

	CATextLayer *layer = ...*
	[layer setWritableAccessibilityAttribute:NSAccessibilityTitleAttribute readBlock:^id{
		return weakLayer.string;
		} writeBlock:^(NSString *value) {
		weakLayer.string = value;
	}];
```
This method will provide a settable attribute to the CALayer. Because every settable attribute needs to be readable, too, you must provide a getter block.
```objective-c
-(void)setParameterizedAccessibilityAttribute:(NSString*)parameterizedAttribute withBlock:(id(^)(id))handler;

	[layer setParameterizedAccessibilityAttribute:NSAccessibilityLineForIndexParameterizedAttribute
										withBlock:^id(id param) {
											return @0;
										}];
```
Same principle here, you provide a block, which will be invoked when the system ax-service asks the layer for a parameterized accessibility value (such as the current cursor position in a text field).

```objective-c
-(void)setAccessibilityAction:(NSString*)actionName withBlock:(void(^)(void))handler

	[layer setAccessibilityAction:NSAccessibilityPressAction
						withBlock:^{
							NSLog(@"action pressed");
						}];
```
Since the handler blocks are stored on the individual layers, you need to be careful to avoid retain-cycles, when you back reference the layer in these blocks. Always use a weak self reference inside the block and transform it back to a strong reference in the block.

For a detailed example how to use the library, have a look in the LayerView class.

Since the library implements a lot of default NSAccessibility attributes, you only need to provide the attributes which are specific to your UI. The build in attributes are the following:

**NSAccessibilityRoleAttribute**  
**NSAccessibilityParentAttribute**  
**NSAccessibilitySizeAttribute**  
**NSAccessibilityPositionAttribute**  
**NSAccessibilityWindowAttribute**  
**NSAccessibilityTopLevelUIElementAttribute**  
**NSAccessibilityRoleDescriptionAttribute**  
**NSAccessibilityEnabledAttribute**  
**NSAccessibilityFocusedAttribute** 

The default value for **NSAccessibilityRoleAttribute** is **NSAccessibilityUnknownRole**, so you should provide your own handler which returns a more specific role, such as NSAccessibilityButtonRole or NSAccessibilityTextFieldRole. See the sample project for details.

Every layer without at least one user defined handler is ignored per default. To provide the default handlers for the layers size, position, parent etc, it is needed to call one additional method in your custom NSView when you set the views layer:
```objective-c
 	CALayer *layer = [self createBackgroundLayer];
	[self setAccessiblityEnabledLayer:layer];
```

Then you need to implement only two stub methods from the NSAccessibility protocol in your custom view:
```objective-c
	-(NSArray*)accessibilityAttributeNames
	{
		static NSMutableArray *attributes = nil;
		if (!attributes) {
			attributes = [[super accessibilityAttributeNames] mutableCopy];
			NSArray *appendedAttributes = @[NSAccessibilityChildrenAttribute];

			for (NSString *attribute in appendedAttributes) {
				if (![attributes containsObject:attributes]) {
					[attributes addObject:attribute];
				}
			}
		}
		return attributes;
	}

	-(id)accessibilityAttributeValue:(NSString *)attribute
	{
		if ([attribute isEqualToString:NSAccessibilityChildrenAttribute]) {
			return NSAccessibilityUnignoredChildren(@[self.layer]);
		}
		return [super accessibilityAttributeValue:attribute];
	}
```
Have a look in the LayerView class of the provided example.

The library is fully unit tested with [Kiwi](https://github.com/allending/Kiwi) specs.
## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.  
Then enable accessibility in system settings and start the accessibility inspector afterwards.  
![Enable AX](https://raw.github.com/mmllr/MMLayerAccessibility/master/Resources/enableax.png) 
![AX Inspector](https://raw.github.com/mmllr/MMLayerAccessibility/master/Resources/Xcode.png)
You can examine your CALayer based ui in the inspector.  
![examine ui](https://raw.github.com/mmllr/MMLayerAccessibility/master/Resources/screenshot01.png)


## Requirements

Minimum requirements are Mac OSX 10.7 and ARC.

## Installation

MMLayerAccessibility is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

	pod "MMLayerAccessibility"

## Author

Markus Mueller, mmlr@gmx.net

## License

MMLayerAccessibility is available under the MIT license. See the LICENSE file for more info.
