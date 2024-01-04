################################################################################
#                
#                dProbTrtE = probability that patients receive treatment  E
#   
#   Return: 0 for S and 1 for E
################################################################################
GetTreatment <- function( dProbTrtE )
{
    
    nTrt <- rbinom( 1, 1, dProbTrtE )
    
    return( nTrt )
}