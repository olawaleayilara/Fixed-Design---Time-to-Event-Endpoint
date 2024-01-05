
# Simulation for Bayesian Adaptive Design: Time-to-event Endpoint I 


This repository is an introduction to simulation of adaptive clinical trials. The programming style used in this example was intentionally kept simple for clarity.

# Introduction

This example illustrates a fixed sample design within the Bayesian framework. I will introduce the adaptive design for this problem in Part II.

**Hypothetical example.** Suppose that an investigator is planning a trial to study a new drug that can potentially prevent infection- and cardiovascular-related hospitalization and death in survivors of hospitalization from a severe infection after their hospital discharge.

Patients will be randomized to either an experimental drug arm $(E)$ or standard-of-care $(S)$. The primary objective is to compare the treatment effect on patients randomized to $(E)$ or $(S)$. The primary outcome is the time-to-first occurrence of composite of infection- and cardiovascular-related hospitalization, or death, up to 1 year. The trial is planned to recruit patients for 3 years with a maximum of 1-year follow-up. The primary analysis will test the following hypotheses:

```math
H_0: HR_{E/S} = 1 \, \, \, vs \, \, \, H_a: HR_{E/S} < 1,
```
where, $`HR_{E/S}`$ is the hazard ratio of $(E)$ relative to $(S)$.

**Assumptions**

-   1:1 randomization
-   Uniform recruitment
-   Expected control event rate (CER) is assumed to $`35\%`$ during the 1-year observation period
-   Exponentially distributed time to event
-   Minimal clinically important difference is assumed to be between $`15\% - 20\%`$ reduction in relative hazard
-   Operating characteristics (OCs) are summarized for $HR = 0.80$, which is the expected treatment effect. However, this example can be repurposed to evaluate OCs for any HR
-   $`80\%`$ statistical power

# Method

## Statistical Formulation

Consider a two-arm parallel randomized controlled trial with time-to-event endpoint. Let $Y_i$ be the time to event for patient $i$, for $i = 1, \ldots, N$. Let the treatment group for patient $i$ be $g_i$, where $g = 1$ refers to the $(S)$ and $g = 2$ refers to the $(E)$.

For ease of computation and explanation, we assume an exponential time-to-event model, 
```math
f(t)  = \lambda_g \exp (-\lambda_gt), \, \, \, \, g = 1,2
```
and independent prior distributions for the two treatment hazard rates, 
```math
 \lambda_g \sim \Gamma (\alpha , \beta ), \, \, \, \, g = 1,2
```
These prior distributions are equivalent to assuming $`\alpha`$ event in $`\beta`$ years/weeks/days (depending on the unit of time in the model).

The posterior distributions for the two treatment hazard rates given the data can be written as: 
```math
\lambda_g | X_g, E_g  \sim \Gamma (\alpha + X_g , \beta + E_g ), \, \, \, \, g = 1,2   
```
where, $`X_g`$ and $`E_g`$ are number of events and exposure time, respectively.

The posterior distribution of the parameters can be estimated using different computational techniques. In this example, we used the Markov Chain Monte Carlo (MCMC) method.

See [[Berry et al. (2010)]](#1), [[Kruschke (2014)]](#2) for Bayesian computational methods.

## Adaptive Design

### Timing of Analyses

This example is a fixed sample trial. Hence, no interim analysis is specified.

### Trial Conclusion

For this example, the trial will conclude that $`E`$ is superior to $`S`$ if the posterior probability of the hazard ratio exceeds $`0.975`$ (i.e., $`Pr(HR_{E/S} < 1 | data) > 0.975`$).

## Simulation

### Task (see, [[Wathen (2019)]](#3))

1.  Simulate the arrival times for all patients

2.  Randomize each patient to a treatment

3.  Use the treatment to simulate patient outcomes.

4.  Analyze the data to compute $Pr(HR_{E/S} < 1 | data)$ using all patient data.

5.  Make a decision at the end of the study

### Operating Characteristics

Operating characteristics, including false-positive, power, average number of events and sample size are calculated based on $500$ simulation iterations per scenario

# Computation

Programming convention including naming of functions, in this example is an adaptation from [[Wathen (2019)]](#3).

Refer to the **.R** files for scripts used in this example.

1. **MainI.R**: This code explores one simulation scenario 

2. **MainII.R**: This code explores more than one scenario


## Simulation Results (from MainII.R)
Roughly speaking, with $`2500`$ patients we can achieve a relative reduction of $`>= 20\%`$ with $`80\%`$ statistical power for all the control event rate. Hence, in the next example (i.e., adaptive example) we would aim to achieve a relative reduction of $`20\%`$ with $`2500`$ patients and $`35\%`$ control event rate.

Check out "Simulation for Bayesian Adaptive Design: Time-to-event Endpoint II"

**Feedback.** I have worked several hours to put these materials together, and I would like to make it better. Please provide suggestions (BE POLITE) via email (ayilara.wale\@gmail.com).

 

# References

<a id="1">[1]</a> 
Berry, S. M., Carlin, B. P., Lee, J. J., & Muller, P. (2010). Bayesian adaptive methods for clinical trials. CRC press.

<a id="2">[2]</a> 
Kruschke, J. (2014). Doing Bayesian data analysis: A tutorial with R, JAGS, and Stan.

<a id="3">[3]</a> 
Wathen, J. K. (2019). Simulation for Bayesian Adaptive Designs—Step-by-Step Guide for Developing the Necessary R Code. In Bayesian Applications in Pharmaceutical Development (pp. 267-285). Chapman and Hall/CRC.
