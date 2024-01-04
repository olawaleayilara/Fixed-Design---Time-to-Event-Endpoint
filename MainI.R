library(tidyverse)

# Source the files for this project
source( "SimulateArrivalTimes.R" )
source( "Randomizer.R" )
source( "SimulatePatientOutcome.R" )
source( "AnalysisMethods.R" )
source( "Functions.R" )
source( "SimulateTrial.R" )

source( "ThemeGGplot.R" )

########################## Setup Design Parameters #############################

nQtyReps             <- 500                       # The number of virtual trials to simulate

nMaxQtyOfPats        <- 2500                      # The maximum number of patients

dTargetHazardRatio   <- 0.80                      # Expected treatment effect

dRelativeReduction   <- 1 - dTargetHazardRatio    # Target relative reduction in hazard ratio

dTrueEventS          <- 0.35                      #  Control event rate for a year

dHazardRateS         <- -log(1 - dTrueEventS) / 1  # Control hazard rate per year

dHazardRateE         <- dTargetHazardRatio * dHazardRateS # Exp hazard rate per year

dTrueEventE          <-  1 - (exp(-dHazardRateE))   #  Exp event rate for a year

dAbsoluteRed         <-  dTrueEventS - dTrueEventE  # Absolute reduction

dTestHazardRatio     <- 1                           # Hypothesized HR

dRecruitTime         <- 36                          # Recruitment duration

dFollowUp            <- 12                          # Follow-up duration

dQtyPatsPerMonth    <- nMaxQtyOfPats / dRecruitTime    # Number of patients that will be enrolled each month

# Specify the Priors: lambda_S ~ Gamma( 1, 0.08 ); lambda_E ~ Gamma( 1, 0.08 )
dPriorAS     <- 1  
dPriorBS     <- 0.08  

dPriorAE     <- 1  
dPriorBE     <- 0.08


# Decision criteria  At the end of the study E will be selected if
# Select treatment E if Pr( HR < 1 | data ) > dPU
# Select treatment S if Pr( HR < 1 | data ) < dPL
dPU          <- 0.975   
dPL          <- 0.025


# First: Simulate a single trial to understand the outputs and the parameters 
# before launching a loop with many virtual trial

lSimulatedTrial <- SimulateSingleTrial(nMaxQtyOfPats,
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

# Results variables
vResults        <- numeric()
vHazardResults  <- numeric()
vCurrent        <- numeric()
mQtyPats        <- matrix( NA, nrow = nQtyReps , ncol = 2)
mQtyEvents      <- matrix( NA, nrow = nQtyReps , ncol = 2)


######## Looping over many virtual trial  #####
for( i in 1:nQtyReps ) {
    
    lSimulatedTrial <- SimulateSingleTrial(nMaxQtyOfPats,
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
    
    
    vResults[ i  ]      <- lSimulatedTrial$nDecision
    vHazardResults[ i ] <- lSimulatedTrial$dEstimatedHazardRatio
    mQtyPats[ i, ]      <- lSimulatedTrial$vQtyPats
    mQtyEvents[ i, ]    <- lSimulatedTrial$vQtyEvents
    
    vCurrent [ i  ]     <- lSimulatedTrial$dCurrentTime
    
    
}

#   Print the Operating Characteristics #####

ProbSelectNone <- sum( vResults == 1) / nQtyReps
ProbSelectS    <- sum( vResults == 2) / nQtyReps 
ProbSelectE    <- sum( vResults == 3) / nQtyReps

print( paste( "The probability that the trial will select no treatment arm is ", ProbSelectNone))
print( paste( "The probability that the trial will select the S arm is ", ProbSelectS))
print( paste( "The probability that the trial will select the E arm is ", ProbSelectE))


dAveCurrentTime <- round(mean( vCurrent ), 2)
print( paste("The average time of analysis is ", dAveCurrentTime))


vAveQtyPats <- apply( mQtyPats, 2, mean)
print( paste("The average number of patient on the S arm is ", vAveQtyPats[1]))
print( paste("The average number of patient on the E arm is ", vAveQtyPats[2]))


vAveQtyEvents <- apply( mQtyEvents, 2, mean)
print( paste("The average number of event is ", vAveQtyEvents[2]))
