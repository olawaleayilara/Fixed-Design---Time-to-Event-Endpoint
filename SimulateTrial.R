########## File Header #########################################################
#
#   Description:    This function simulates a virtual trial
#
#   Input           nMaxQtyOfPatient    The maximum number of patients in the trial
#                   dQtyPatsPerMonth    The expected number of patients accrued each month
#                   dPriorAS, dPriorBS  Prior parameters for S where Q_S ~ Beta(dPriorAS, dPriorBS) a priori 
#                   dPriorAE, dPriorBE  Prior parameters for E where Q_E ~ Beta(dPriorAE, dPriorBE) a priori 
#                   dPU                 Select treatment E if Pr(HR_{E/S} < 1 | data) > dPU
#                   dHazardRateS        The true hazard rate for S
#                   dHazardRateE        The true hazard rate for E
#
#                   Return              A list with the following items
#                                       nDecision with 1 if no treatment is selected, 2 if S is selected 3 if E is selected, 
#                                       
################################################################################

SimulateSingleTrial <- function(nMaxQtyOfPats,
                                dQtyPatsPerMonth,
                                dPriorAS, 
                                dPriorBS,
                                dPriorAE, 
                                dPriorBE,
                                dPU,
                                dPL,
                                dHazardRateS,
                                dHazardRateE,
                                dFollowUp,
                                dTestHazardRatio)
{
    # Setup the variables needed in this function
    vPatOutcome <- rep(NA, nMaxQtyOfPats)         # Vector that contains the patients outcome
    vPatEvent   <- rep(NA, nMaxQtyOfPats)         # Vector that contains the patients event
    vTreat      <- rep(NA, nMaxQtyOfPats)         # Vector that contains the patients treatment S = 0, E = 1
    vQtyPats    <- rep(0, 2)                      # Vector to keep track of the number of patients on S and E 
    vQtyEvents  <- rep(0, 2)                      # Vector to keep track of the number of events on S and E
    
    # Simulate arrival times and times the outcomes are observed
    vStartTime   <- SimulateArrivalTimes( dQtyPatsPerMonth, nMaxQtyOfPats )
    
    
     vObsTime    <- vStartTime + dFollowUp # 12 months follow-up

    
     #  Randomize and simulate the patient outcomes
     for(i in 1:nMaxQtyOfPats)
     {
         vTreat[i]         <- GetTreatment(0.5) 
         vPatOutcome[i]    <- SimulatePatientOutcome(vTreat[i], dHazardRateS, dHazardRateE) 
         vPatEvent[i]      <- SimulatePatientEvent( vPatOutcome[i]) 
         
         vQtyPats[vTreat[i] + 1]      <- vQtyPats[vTreat[i] + 1] + 1
         vQtyEvents[vPatEvent[i] + 1] <- vQtyEvents[vPatEvent[i] + 1] + 1
         
     }
     
        
    dCurrentTime    <- vObsTime[nMaxQtyOfPats] + 0.00001  # Adding 0.0001 to make sure all patient outcomes are observed
    
    lResult         <- RunAnalysis (  dCurrentTime, 
                                      vPatOutcome, 
                                      vPatEvent,
                                      vTreat, 
                                      vObsTime, 
                                      dPriorAS,
                                      dPriorBS, 
                                      dPriorAE, 
                                      dPriorBE,
                                      dTestHazardRatio )
    
    dProbHazardRatioLessTestHR    <- lResult$dProbHazardRatioLessTestHR
    
    dEstimatedHazardRatio          <- lResult$dHazardRatio
    
    nDecision                      <- MakeDecision(dProbHazardRatioLessTestHR, dPU, dPL)
    
    
    lRet <- list(nDecision = nDecision, 
                 dPU = dPU, 
                 dPL = dPL, 
                 vQtyPats = vQtyPats,
                 vQtyEvents = vQtyEvents,
                 vPatOutcome = vPatOutcome, 
                 vTreat = vTreat, 
                 dEstimatedHazardRatio  = dEstimatedHazardRatio,
                 dCurrentTime = dCurrentTime, 
                 vObsTime = vObsTime)
    
    
    return(lRet)
    
}


