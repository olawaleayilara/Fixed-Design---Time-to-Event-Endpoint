########### File Header ########################################################
#
#
#   Input   dPU         Select treatment E if Pr( HR < 1 | data ) > dPU
#           dPL         Select treatment S if Pr( HR < 1 | data ) < dPL
#           dProbHazardRatioLessTestHR
#
#   Returns: 1 --> No treatment selected
#            2 --> S was selected
#            3 --> E was selected
################################################################################

MakeDecision <- function( dProbHazardRatioLessTestHR, dPU, dPL )
{
    nDecision <- 1
    if( dProbHazardRatioLessTestHR < dPL  )
        nDecision <- 2
    else if( dProbHazardRatioLessTestHR > dPU )
        nDecision <- 3
    return( nDecision )
}
