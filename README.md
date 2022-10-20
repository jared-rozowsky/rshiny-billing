# rshiny-billing
shiny app to view billing information from CAVATICA

This is a shiny app to visualize [CAVATICA](cavatica.org) billing groups using the R-API. The goal of this project was to create a more automated way of viewing the status of each billing group as well as the billing group breakdown. Users can only view billing groups of which they are an admin. 

Note: to make this work, the original [sevenbridges-r](https://github.com/sbg/sevenbridges-r) package had to be modified. The modified version required to make the shiny app work is [here](https://github.com/jared-rozowsky/sevenbridges-jr)

Specifically, the class-auth.R, api-http.R, and zzz.R files were modified.

## Guide:
Launch the shiny app in app.R

Once the app is launched, copy and paste your own CAVATICA token. Your token can be found by logging in to your account, go to the "Developer" tab at the top, and then "Authentication Token". 
