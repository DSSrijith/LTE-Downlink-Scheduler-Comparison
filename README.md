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
| Path-loss model | Exponent 3.5, referenced at 100 m | Models distance-dependent average SNR. |
| Fading model | AR(1) approximation of Jakes' model | Provides Doppler-dependent temporal correlation. |
| Rate model | Shannon: W log2(1 + SNR) | Isolates scheduler behavior without MCS quantization. |
| Number of users | 10 by default | Baseline cell load; E1 varies it. |
| PF averaging window | 100 TTIs by default | Sets the PF throughput-memory timescale; E2 varies it. |
| Traffic model | Full buffer | Every user always has data available. |

## Repository structure

```
.
|-- AGENTS.md                     # Standing instructions for future Codex sessions.
|-- LICENSE                       # MIT license.
|-- README.md                     # Project documentation.
|-- .gitignore                    # Generated/local-file ignore rules.
|-- default_params.m              # Default simulation parameters.
|-- gen_fading.m                  # Correlated Rayleigh fading generator.
|-- user_setup.m                  # User distance and average-SNR generator.
|-- compute_rate.m                # Idealized Shannon-rate calculation.
|-- select_user.m                 # RR, Max-C/I, and PF selection logic.
|-- update_average.m              # Exponential throughput-average update.
|-- run_simulation.m              # Stateful scheduler simulation.
|-- jain_index.m                  # Jain fairness-index calculation.
|-- generate_channels.m           # Seeded shared channel generation.
|-- run_experiment_E1.m           # User-count experiment.
|-- run_experiment_E2_tc.m        # PF averaging-window experiment.
|-- run_experiment_E3_doppler.m   # Doppler experiment.
|-- run_experiment_E4_distance.m  # Distance experiment.
|-- main.m                        # Full experiment entry point.
|-- tests/
|   `-- sanity_checks.m            # Required pre-experiment validation.
|-- results/                      # Generated CSV data after main.m runs.
`-- plots/                        # Generated PNG figures after main.m runs.
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

The full experiment suite can take several minutes, depending on hardware. Results are reproducible because the experiment seeds are fixed.

## Experiments

| ID | What varies | What is measured | Output file |
| --- | --- | --- | --- |
| E1 | Number of users K | Cell throughput, Jain index, 5th-percentile throughput | `results/E1_users.csv` |
| E2 | PF averaging window t_c | Cell throughput, Jain index, 5th-percentile throughput | `results/E2_tc.csv` |
| E3 | Maximum Doppler frequency | Cell throughput, Jain index, 5th-percentile throughput | `results/E3_doppler.csv` |
| E4 | Maximum user distance | Cell throughput, Jain index, 5th-percentile throughput | `results/E4_distance.csv` |

## Results

Results will be added after running main.m. Figures are saved in plots/ and data in results/.

## Limitations

- Shannon rate instead of a CQI-to-MCS mapping.
- No HARQ.
- No control-channel overhead.
- Single cell.
- Ideal CQI feedback.
- Full-buffer traffic.
- AR(1) approximation of Jakes' model.

## Reproducibility

Each experiment uses seeds 1 through 10. For a given seed, user locations are drawn after `rng(seed)`, then `generate_channels` resets the same seed and generates user rows in order. All schedulers within that seed receive identical user average SNRs and channel matrices, making their comparison directly reproducible and fair.

## License

MIT. See [LICENSE](LICENSE).

## References

- Jalali, Padovani, and Pankaj, "Data Throughput of CDMA-HDR a High Efficiency-High Data Rate Personal Communication Wireless System," IEEE VTC 2000.
- Jain, Chiu, and Hawe, "A Quantitative Measure of Fairness and Discrimination for Resource Allocation in Shared Computer Systems," DEC Technical Report TR-301, 1984.
- Dahlman, Parkvall, and Skold, "4G LTE/LTE-Advanced for Mobile Broadband," Academic Press, 2011.
- Jakes, "Microwave Mobile Communications," Wiley, 1974.
