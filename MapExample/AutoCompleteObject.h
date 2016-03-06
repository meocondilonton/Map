

#import <Foundation/Foundation.h>

/*
 In some cases you may want strings in an autocomplete menu to be associated to some kind of model object
 (For example: a list of names may be
 associated with friend objects and you want to track which friend object a
 user selects based on what name they choose from the autocomplete list.)
 
 In order to pass your model objects straight to the MLPAutoCompleteTextFieldDataSource's
 autoCompleteTextField:possibleCompletionsForString: method, your model object must implement this protocol.
 */
@protocol AutoCompleteObject <NSObject>
@required

/*Return the string that should be displayed in the autocomplete menu that
 represents this object. (For example: a person's name.)*/
- (NSString *)autocompleteString;

@end