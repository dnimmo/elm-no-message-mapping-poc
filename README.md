# What is this?

This is a basic example to play with the idea of using the URL to handle state changes in an Elm application, to avoid situations where you want a "child" state to do some stuff, only to then have a "parent" state do something different when the "child" state meets certain conditions. 

## How can I run this locally? 

Make sure you have `elm-live` installed (`npm -g elm-live`), and then run `./dev.sh`.

## Interesting bits to look at

### Main.Model 

Stores a `Maybe User` at all times - this is so that the `User` can be passed in to any module that needs it. On initial load, if there's a user signed in already, this user will be passed in on `Main.init`. 

### Route

Records all the possible routes, and acts as the go-to module for anything to do with route changes via `link`.

### Main.handleUrlChange

As the name suggests, this function handles changes to the URL. The URL is parsed into a `Route`, and the state is updated depending on the Route in question. In the case of the `Home` Route, this redirects to the `Dashboard` Route if there's a user logged in already.

### Page.Account.update 

This function returns an updated `Account.Model`, a `Cmd Account.Msg`, and a `Maybe User`. The `Maybe User` is used to flag any updates to the logged in User that happen whilst the User is in the `Account` page. If this function returns `Just User`, then the User stored in `Main.Model` is replaced. Otherwise, the User that was already in `Main.Model` is retained.  