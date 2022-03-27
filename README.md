# What is this?

This is a basic example to play with the idea of using the URL to handle state changes in an Elm application, to avoid situations where you want a "child" state to do some stuff, only to then have a "parent" state do something different when the "child" state meets certain conditions. 

## How can I run this locally? 

Make sure you have `elm-live` installed (`npm -g elm-live`), and then run `./dev.sh`.

## How can I log in?

Use `test@test.com` and `password1` to access this very secure site. :D 

## Interesting bits to look at

### The User module

This module stores the User's state - that is, whether they're logged in or not. When logged in, this module's `Model` will also store the logged in User. Whenever the User's details are updated, this module's Model is updated (via a subscription). 

### Main.Model 

Stores a `User.Model` at all times - this is so that the `User` can be passed in to any module that needs it. On initial load, if there's a user signed in already, this user will be passed in on `Main.init`. 

### Route

Records all the possible routes, and acts as the go-to module for anything to do with route changes via `link`.

### Main.handleUrlChange

As the name suggests, this function handles changes to the URL. The URL is parsed into a `Route`, and the state is updated depending on the Route in question. In the case of the `Home` Route, this redirects to the `Dashboard` Route if there's a user logged in already.

## When the User's name is updated, what happens? 

Excellent question. Entirely coincidentally, this is the reason this example exists in the first place!

What happens is this: 

The user submits their new name
-> The User's account (outside of the Elm application) is updated with the new name
-> The `User.storedUserUpdated` subscription is triggered with the updated User details
-> This subscription is being listened to by both `User` and `Page.Account`
    -> `User.update` updates the User that is stored in its Model
    -> `Page.Account.update` only checks to see whether a valid User was received
        -> If a valid User was received, the user is redirected to `ViewAccount` as we know that their update succeeded
        -> If a valid User was not received, the user is presented with an error message to tell them that their update failed