################################################################################
#
#   Description: 	This file contains functions for simulating the patient data.
#
#   Input           nTreat          Treatment the patient received, 0 for S and 1 for E
#                   dHazardRateS    The true hazard rate for S
#                   dHazardRateE    The true hazard rate for E
#
#   Return          nOutcome        Time to event censored at t (12 months)
#                   nEvent          Status of the patient, 1 for event, 0, for no event
#
#
################################################################################

SimulatePatientOutcome <- function( nTreat, dHazardRateS, dHazardRateE )
{
   
    
    if( nTreat == 0 )  # Patient received S
    {
        nOutcome <- rexp(1, dHazardRateS)
        
    }
    
    else if( nTreat == 1 ) # Patient received E
    {
        nOutcome <- rexp(1, dHazardRateE)
        
    }
    
    
    return( nOutcome )
}


SimulatePatientEvent <- function( vOutcome )
    {
    
        nEvent       <-  ifelse(vOutcome <= 1, 1, 0)      # 1 here means 12 months
    
    return( nEvent )
}

