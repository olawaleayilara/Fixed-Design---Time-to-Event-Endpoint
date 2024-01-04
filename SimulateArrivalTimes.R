########### File Header ########################################################
#  
#   Description: This function simulates arrival times, according to Poisson process
#                for each patient in the study
#   
#   Inputs:  dPatsPerMonth   The expected number of patients accrued each month. 
#                            Recruitment will follow a Poisson process
#
#            nMaxQtyPats    The quantity of patient arrival times to simulate
#
################################################################################

SimulateArrivalTimes <- function(dPatsPerMonth, nMaxQtyOfPats)
{ 
  
  vTimes <- cumsum(rexp(nMaxQtyOfPats,dPatsPerMonth))
  return(vTimes)
  
}


