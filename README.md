# LTE Downlink Scheduler Comparison

LTE downlink scheduler comparison (RR, Max-C/I, PF) in MATLAB. This project simulates a single LTE downlink cell to quantify how scheduler choice balances cell capacity, cell-edge service, and user fairness at the MAC layer.

## Table of contents

- [Background](#background)
- [Features](#features)
- [System model and assumptions](#system-model-and-assumptions)
- [Repository structure](#repository-structure)
- [Requirements](#requirements)
- [How to run](#how-to-run)
- [Experiments](#experiments)
- [Results](#results)
- [Limitations](#limitations)
- [Reproducibility](#reproducibility)
- [License](#license)
- [References](#references)

## Background

The LTE MAC scheduler assigns each transmission time interval (TTI) to a user. Round-Robin (RR) rotates users for simple time fairness, Max-C/I selects the user with the highest instantaneous rate for capacity, and Proportional Fair (PF) balances instantaneous opportunity against historical service. Jain's fairness index summarizes how evenly throughput is distributed, where 1 is perfectly equal and lower values indicate disparity. PF uses this metric:

```
m_k(t) = r_k(t) / R_k(t)
```

Here r_k(t) is the instantaneous achievable rate of user k in TTI t, and R_k(t) is the exponentially averaged throughput of user k. PF serves the user with the largest ratio.

## Features

- RR, Max-C/I, and PF scheduler simulations with one scheduled user per TTI.
- Distance-based path loss and temporally correlated Rayleigh fading.
- Cell throughput, per-user throughput, 5th-percentile throughput, and Jain's fairness index.
- Four experiments covering user count, PF averaging window, Doppler frequency, and maximum user distance.
- Fixed seeds, CSV outputs, and headless PNG figures for reproducible experiments.

## System model and assumptions

| Parameter | Value | Reason |
| --- | --- | --- |
| Bandwidth | 10 MHz | Typical LTE-scale carrier bandwidth used in the rate model. |
| TTI | 1 ms | LTE scheduling interval. |
| Simulation length | 20,000 TTIs (20 s) per run | Fixed run length, so every scheduler is compared over the same number of TTIs. |
| Path-loss model | Exponent 3.5, referenced at 100 m | Models distance-dependent average SNR. |
| Average SNR at 100 m | 30 dB | Sets the cell's link budget. |
| Fading model | AR(1) approximation of Jakes' model | Provides Doppler-dependent temporal correlation. |
| Rate model | Shannon: W log2(1 + SNR) | Isolates scheduler behavior without MCS quantization. |
| Number of users | 10 by default | Baseline cell load; E1 varies it. |
| PF averaging window | 100 TTIs by default | Sets the PF throughput-memory timescale; E2 varies it. |
| Traffic model | Full buffer | Every user always has data available. |
| Random seeds | 10 per experiment point | Gives a mean and 95% confidence interval for each point. |

## Repository structure

```
.
├── AGENTS.md                       # Standing instructions for future Codex sessions.
├── LICENSE                         # MIT license.
├── README.md                       # Project documentation.
├── .gitignore                      # Generated and local-file ignore rules.
├── default_params.m                # Default simulation parameters.
├── gen_fading.m                    # Correlated Rayleigh fading generator.
├── user_setup.m                    # User distance and average-SNR generator.
├── compute_rate.m                  # Idealized Shannon-rate calculation.
├── select_user.m                   # RR, Max-C/I, and PF selection logic.
├── update_average.m                # Exponential throughput-average update.
├── run_simulation.m                # Stateful scheduler simulation.
├── jain_index.m                    # Jain fairness-index calculation.
├── generate_channels.m             # Seeded shared channel generation.
├── run_experiment_E1.m             # User-count experiment.
├── run_experiment_E2_tc.m          # PF averaging-window experiment.
├── run_experiment_E3_doppler.m     # Doppler experiment.
├── run_experiment_E4_distance.m    # Distance experiment.
├── main.m                          # Full experiment entry point.
├── tests/
│   └── sanity_checks.m             # Required pre-experiment validation.
├── results/                        # Generated CSV data after main.m runs.
└── plots/                          # Generated PNG figures after main.m runs.
```

## Requirements

- MATLAB R2021a or later.
- Base MATLAB only.
- No toolboxes.

## How to run

Open MATLAB, set the current folder to the project root, and run `main`. From PowerShell in the project root, run:

```powershell
& "C:\Program Files\MATLAB\R2026b\bin\matlab.exe" -batch "run('main.m')"
```

The sanity checks run first. The full experiment suite (E1 to E4, 10 seeds each) takes about one minute on a typical laptop. Results are reproducible because the experiment seeds are fixed. A non-zero exit code means a sanity check failed.

## Experiments

| ID | What varies | What is measured | Output file | Plot |
| --- | --- | --- | --- | --- |
| E1 | Number of users K (2 to 20) | Cell throughput, Jain index, 5th-percentile throughput | `results/E1_users.csv` | `plots/E1_cell_tp_vs_K_T20000_seeds10.png`, `plots/E1_jain_vs_K_T20000_seeds10.png` |
| E2 | PF averaging window t_c (1 to 1000 TTIs) | Cell throughput, Jain index, with RR and Max-C/I as reference | `results/E2_tc.csv` | `plots/E2_tc_tradeoff_K10_seeds10.png` |
| E3 | Maximum Doppler frequency (5, 50, 200 Hz) | Cell throughput per scheduler | `results/E3_doppler.csv` | `plots/E3_doppler_K10_seeds10.png` |
| E4 | Maximum user distance (300 to 1500 m) | 5th-percentile throughput, cell throughput, Jain index | `results/E4_distance.csv` | `plots/E4_distance_K10_seeds10.png` |

Error bars on E1 to E4 show the 95% confidence interval across the 10 seeds, computed as 1.96 × standard deviation / √n.

## Results

Results come from one run of `main.m` with the default parameters (K=10, t_c=100, fd=10 Hz, seed 1). These are single-seed values, so they show the scale of each scheduler rather than averages.

| Scheduler | Cell throughput (Mbps) | Jain index | 5th-percentile throughput (kbps) |
| --- | --- | --- | --- |
| RR | 39.34 | 0.723 | 750.1 |
| Max-C/I | 93.36 | 0.129 | 0.0 |
| PF | 41.16 | 0.729 | 825.2 |

Trends from the full experiments (means over 10 seeds, read from the figures and checked against the CSVs):

- **Users (E1):** Max-C/I gives the highest cell throughput at every K, rising from about 42 Mbps at K=2 to about 88 Mbps at K=20. Its Jain index falls from about 0.58 to about 0.10. RR and PF stay near 25 to 30 Mbps, with PF slightly above RR.
- **PF window (E2):** For t_c of 10, 100, and 1000, PF's cell throughput and Jain index both rise with t_c (Jain from about 0.61 to about 0.66), and PF stays slightly above RR on both measures. At t_c = 1 the result is a degenerate artifact of the averaging update (see Limitations), not a property of PF. In this sweep we did not observe a throughput-fairness trade-off.
- **Doppler (E3):** RR stays flat at about 28 Mbps. PF rises from about 29 Mbps to about 44 Mbps as the Doppler frequency increases, because faster fading gives PF more chances to serve users near their channel peaks. Max-C/I stays near 80 Mbps.
- **Distance (E4):** Cell throughput and 5th-percentile throughput fall as the cell grows. Max-C/I's 5th-percentile throughput is zero in 39 of 40 runs, which shows starvation of the worst user.

## Limitations

- Shannon rate instead of a CQI-to-MCS mapping.
- No HARQ.
- No control-channel overhead.
- Single cell.
- Ideal CQI feedback.
- Full-buffer traffic.
- AR(1) approximation of Jakes' model.
- With K=10, the 5th-percentile throughput is the minimum user, not an interpolated percentile.
- At t_c = 1, the averaging update sets every unscheduled user's average to zero. The PF metric then becomes infinite for them, so from the second TTI onward the scheduler alternates between users 1 and 2 (the two lowest indices). Only three users are ever scheduled (user 6 wins the first TTI, when all averages are still at their initial value). The t_c = 1 point in E2 therefore reflects this tie-breaking behavior, not PF performance.

## Reproducibility

Each experiment uses seeds 1 through 10. For a given seed, user locations are drawn after `rng(seed)`, then `generate_channels` resets the same seed and generates user rows in order. All schedulers within that seed receive identical user average SNRs and channel matrices, making their comparison directly reproducible and fair.

Repeated runs of `main.m` on the same machine produced identical CSV hashes in our check. The sanity checks use a fixed seed, so their printed values are also repeatable. They do not feed into the CSVs.

## License

MIT. See [LICENSE](LICENSE).

## References

- Jalali, Padovani, and Pankaj, "Data Throughput of CDMA-HDR a High Efficiency-High Data Rate Personal Communication Wireless System," IEEE VTC 2000.
- Jain, Chiu, and Hawe, "A Quantitative Measure of Fairness and Discrimination for Resource Allocation in Shared Computer Systems," DEC Technical Report TR-301, 1984.
- Dahlman, Parkvall, and Skold, "4G LTE/LTE-Advanced for Mobile Broadband," Academic Press, 2011.
- Jakes, "Microwave Mobile Communications," Wiley, 1974.