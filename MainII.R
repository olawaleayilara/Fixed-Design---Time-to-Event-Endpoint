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

dTargetHazardRatio   <- seq(0.6, 1, 0.05)         # Treatment effects

dRelativeReduction   <- 1 - dTargetHazardRatio    # Target relative reduction in hazard ratio

dTrueEventS          <- c( 0.30, 0.35, 0.40, 0.45 ) #  Control event rate for a year

dHazardRateS         <- -log(1 - dTrueEventS) / 1  # Control hazard rate per year

dHazardRateE         <- data.frame((matrix(dHazardRateS,length(dTrueEventS),1) %*%    
                                    matrix(dTargetHazardRatio,1,length(dTargetHazardRatio))))

colnames(dHazardRateE) <- c(paste("RelReduction",sep="",dRelativeReduction))

dTrueEventE          <-  1 - (exp(-dHazardRateE))   #  Exp event rate for a year

dfdAbsoluteRed       <- bind_cols(crossing(dTargetHazardRatio, dTrueEventS),
                                  dTrueEventE = c(unlist(dTrueEventE))) %>%
                             mutate(AbsoluteRed  = round((dTrueEventS - dTrueEventE) * 100, 1))


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

lDesign     <- list()

for(i in 1:length(dTargetHazardRatio)){
    
    lDesign[[i]] <- nesting(dTrueEventS, dTrueEventE[,i], dHazardRateS,dHazardRateE[,i])
    
}


dHazardRate <- bind_rows (lDesign[[1]],
                          lDesign[[2]],
                          lDesign[[3]],
                          lDesign[[4]],
                          lDesign[[5]],
                          lDesign[[6]],
                          lDesign[[7]],
                          lDesign[[8]],
                          lDesign[[9]])

colnames(dHazardRate)         <- c("TrueEventS","TrueEventE","HazardRateS", "HazardRateE")

dHazardRate$TargetHazardRatio <- dHazardRate$HazardRateE / dHazardRate$HazardRateS

dHazardRate$RelativeReduction <- 1 - dHazardRate$TargetHazardRatio

dfModels                      <- crossing(dHazardRate,
                                          TestHazardRatio = dTestHazardRatio,
                                          PriorAS = dPriorAS,
                                          PriorBS = dPriorBS,
                                          PriorAE = dPriorAE,
                                          PriorBE = dPriorBE,
                                          dPU  = dPU,
                                          dPL = dPL,
                                          FollowUp =  dFollowUp,
                                          RecruitTime = dRecruitTime,
                                          QtyPatsPerMonth = dQtyPatsPerMonth,
                                          MaxQtyOfPats = nMaxQtyOfPats )  %>% 
                                          rowid_to_column( "ModelID")


# Results variables
mResults                <- matrix( NA, ncol = nrow(dfModels), nrow = nQtyReps)
mHazardResults          <- matrix( NA, ncol = nrow(dfModels), nrow = nQtyReps)
mCurrentTime            <- matrix( NA, ncol = nrow(dfModels), nrow = nQtyReps)

aQtyPats                <- array( NA, c(nrow = nQtyReps,2,nrow(dfModels)))
aQtyEvents              <- array( NA, c(nrow = nQtyReps,2,nrow(dfModels)))


##################### Start Simulation  ###############################

for( index in 1:nrow(dfModels)){
    for( i in 1:nQtyReps ) {
        
        lSimulatedTrial <- SimulateSingleTrial(nMaxQtyOfPats    = dfModels$MaxQtyOfPats[index],
                                               dQtyPatsPerMonth = dfModels$QtyPatsPerMonth[index],
                                               dPriorAS         = dfModels$PriorAS[index], 
                                               dPriorBS         = dfModels$PriorBS[index],
                                               dPriorAE         = dfModels$PriorAE[index], 
                                               dPriorBE         = dfModels$PriorBE[index],
                                               dPU              = dfModels$dPU[index],
                                               dPL              = dfModels$dPL[index],
                                               dHazardRateS     = dfModels$HazardRateS[index],
                                               dHazardRateE     = dfModels$HazardRateE[index],
                                               dFollowUp        = dfModels$FollowUp[index],
                                               dTestHazardRatio = dfModels$TestHazardRatio[index])
        
        
        mResults[ i , index ]       <- lSimulatedTrial$nDecision
        mHazardResults[ i , index ] <- lSimulatedTrial$dEstimatedHazardRatio
        mCurrentTime[ i , index ]       <- lSimulatedTrial$dCurrentTime
        
        aQtyPats[ i, , index ]      <- lSimulatedTrial$vQtyPats
        aQtyEvents[ i, , index ]    <- lSimulatedTrial$vQtyEvents
        
        
        
        
    }
}
#   Print the Operating Characteristics #####

dProbSelectNone <- numeric()
dProbSelectS    <- numeric() 
dProbSelectE    <- numeric()    
dAveHazardRatio <- numeric() 
dCurrentTime    <- numeric()

mAveQtyPats     <- matrix(NA, nrow(dfModels), 2)
mAveQtyEvents   <- matrix(NA, nrow(dfModels), 2)

for( index in 1:nrow(dfModels)){
    
    dProbSelectNone[index]  <- sum( mResults[,index] == 1) / nQtyReps
    dProbSelectS[index]     <- sum( mResults[,index] == 2) / nQtyReps 
    dProbSelectE[index]     <- sum( mResults[,index] == 3) / nQtyReps
    
    
    dAveHazardRatio[index]  <- round(mean( mHazardResults[,index] ), 2)
    dCurrentTime[index]     <- round(mean( mCurrentTime[,index] ), 2)
    
    mAveQtyPats[index,]     <- round(apply( aQtyPats[,,index],2,mean),1)
    mAveQtyEvents[index,]   <- round(apply( aQtyEvents[,,index],2,mean),1)
    
}

SimResults                  <- bind_cols(TargetHazardRatio = dfModels$TargetHazardRatio,
                                         TrueEventRateS    = dfModels$TrueEventS,
                                         TrueEventRateE    = dfModels$TrueEventE,
                                         RelativeReduction = dfModels$RelativeReduction,
                                         AveHazardRatio    = dAveHazardRatio,
                                         CurrentTime       = dCurrentTime,
                                         ProbSelectNone    = dProbSelectNone,
                                         ProbSelectS       = dProbSelectS,
                                         ProbSelectE       = dProbSelectE,
                                         AveQtyEvents      = mAveQtyEvents[,2])


AveQtyPats                <- data.frame(mAveQtyPats)
colnames(AveQtyPats)      <- c("AvgSampleSizeS","AvgSampleSizeE")
AveQtyPats$AvgSampleSize  <- rowSums(AveQtyPats)


SimResults %>%
    ggplot(aes(x = RelativeReduction, y = ProbSelectE, colour = factor(TrueEventRateS)  )) + 
    geom_point(size = 2) + geom_line(size = 1) +
    geom_vline(xintercept = c(0.20,0.15), colour = "blue",linetype = "dashed") + 
    geom_hline(yintercept = c(0.025,0.8), colour = "red", linetype = "dashed") +
    xlab("Relative Reduction in Hazard") + 
    ylab("Statistical Power") +
    labs(colour = "Control Event Rate") +
    scale_y_continuous(breaks = seq(0, 1, by = 0.1), limits=c(0,1) ) +
    scale_x_continuous(breaks = seq(0,0.4, by = 0.05), limits = c( 0.0, 0.4)) +
    theme(axis.text.x = element_text(size = 13),
          axis.title.x = element_text(size=13),
          axis.text.y = element_text(size = 13),
          axis.title.y = element_text(size=13),
          strip.text = element_text( size=13),
          legend.text = element_text(size=13),
          legend.title = element_text(size=13)) + theme_Publication()





dfdAbsoluteRed   #Absolute Reduction 