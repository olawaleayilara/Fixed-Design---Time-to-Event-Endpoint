# Simulation for Bayesian Adaptive Design: Time-to-event Endpoint I

This repository is an introduction to simulation of adaptive clinical trials. I have worked several hours to put these materials together, and I would like to make it better. Please provide suggestions (BE POLITE) via email (ayilara.wale\@gmail.com).

**NOTE:** The programming style was intentionally kept simple for clarity.

**Hypothetical example.** Suppose that an investigator is planning a trial to study a new drug that can potentially prevent infection- and cardiovascular-related hospitalization and death in survivors of hospitalization from a severe infection after their hospital discharge.

Patients will be randomized to either an experimental drug arm $(E)$ or standard-of-care $(S)$. The primary objective is to compare the treatment effect on patients randomized to $(E)$ or $(S)$. The primary outcome is the time-to-first occurrence of composite of infection- and cardiovascular-related hospitalization, or death, up to 1 year. The trial is planned to recruit patients for 3 years with a maximum of 1 year follow-up. The primary analysis will test the following hypotheses:

$$ H_0: HR_{E/S} = 1 \, \, \, vs \, \, \, H_a: HR_{E/S} < 1,$$

where, $HR_{E/S}$ is the hazard ratio of $(E)$ relative to $(S)$.

Refer to **Main.qmd or Main.html** for explanations and simulation results.
