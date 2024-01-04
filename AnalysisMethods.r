######## File Header ###########################################################################################################################
#
#   
#
#   Description: This file contains functions for running the analysis. 
#
#   Input Arguments:
#       dCurrentTime    The current time in the virtual trial
#       vPatOutcome     A vector of outcomes
#       vPatEvent       A vector of events
#       vTreat          A vector of the treatment the patient received, 0 for S, 1 for E
#       vObsTime        A vector of the times the outcome are observed, patient outcomes are observed sometime after enrollment
#       dPriorAS, dPriorBS  prior parameters for S where Q_S ~ Beta( dPriorAS, dPriorBS ) a priori 
#       dPriorAE, dPriorBE  prior parameters for S where Q_S ~ Beta( dPriorAE, dPriorBE ) a priori 
#   
#   Return: Pr(HR_{E/S} < 1 | data)
#
################################################################################################################################################.

RunAnalysis <- function(  dCurrentTime, 
                          vPatOutcome, 
                          vPatEvent,
                          vTreat, 
                          vObsTime, 
                          dPriorAS,
                          dPriorBS, 
                          dPriorAE, 
                          dPriorBE,
                          dTestHazardRatio  )
{
    # Set the posterior parameters = priors parameters
    
    dPostAS <- dPriorAS
    dPostBS <- dPriorBS
    
    dPostAE <- dPriorAE
    dPostBE <- dPriorBE
    
    # Loop through the data and update the prior parameters to the posterior parameters.
    
    nQtyPats <- length( vPatOutcome )
    
    for( iPat in 1:nQtyPats )
    {
        # Include patient outcomes that were observed prior to dCurrentTime
        
        if( vObsTime[ iPat ] <= dCurrentTime )
        {
            if( vTreat[ iPat ] == 0 )  # Treatment S
            {
                dPostAS <- dPostAS + vPatEvent[ iPat ]
                dPostBS <- dPostBS + min(vPatOutcome[ iPat ], 1)  # 1 means 1 year
                
            }
            else if( vTreat[ iPat ] == 1 )  # Treatment E
            {
                dPostAE <- dPostAE + vPatEvent[ iPat ]
                dPostBE <- dPostBE + min(vPatOutcome[ iPat ], 1)
                
            }
            else
                stop( paste( "Error: In function RunAnalysis an invalid value in vTreat of ", vTreat[ iPat ], " was sent into the function. ") )
        }  
    }
  
    
    
    vHazardRateS <- rgamma( 100000, dPostAS, dPostBS )
    vHazardRateE <- rgamma( 100000, dPostAE, dPostBE ) 
    
    
    dHazardRatio <- mean( vHazardRateE / vHazardRateS )
    dProbHazardRatioLessTestHR <- mean( vHazardRateE / vHazardRateS < dTestHazardRatio )
    
    
    lReturn <- list(dProbHazardRatioLessTestHR = dProbHazardRatioLessTestHR, 
                    dHazardRatio = dHazardRatio)
                
                 
    return(  lReturn )
}

