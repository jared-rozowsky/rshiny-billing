# Function description
# Inputs...

billing_api <- function(token) {

  api <- Auth(platform = "cavatica", token = token) # Sets authorization variables to access api

  api_billing <- api$billing() # Use api to extract information for all billing groups

  billing_data <- vector(mode = "list", length = length(api_billing))

  for (i in seq_along(api_billing)){
    id <- api$billing()[[i]]$id
    billing_data[[i]] <- api$billing(id = id, breakdown = TRUE)
    names(billing_data)[i] <- billing_data[[i]]$summary$name
  }

  return(billing_data)
}