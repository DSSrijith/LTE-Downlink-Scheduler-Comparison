# AGENTS.md

## Running MATLAB
MATLAB R2026b is at: C:\Program Files\MATLAB\R2026b\bin\matlab.exe
Run scripts from the project root with -batch, for example:
& "C:\Program Files\MATLAB\R2026b\bin\matlab.exe" -batch "run('main.m')"
Run the sanity checks before the full experiments:
& "C:\Program Files\MATLAB\R2026b\bin\matlab.exe" -batch "run('tests/sanity_checks.m')"

After each MATLAB run: check the exit code, read the full output, and report any warnings. Never report a result that did not appear in a MATLAB run during the current session.

## Rules
- Base MATLAB only. No toolbox functions.
- Keep LICENSE unchanged.
- Do not run git commit, git push, or any command that changes the remote. The user commits.
- Do not create .mat files in the repository.
- Do not change the seeding scheme in generate_channels.m or user_setup.m without asking the user.
- Create every figure with 'Visible','off' and save it to plots/.
- Do not edit files outside this project folder.

## Reporting at the end of each session
1. The exact MATLAB commands run and their exit codes.
2. The sanity check PASS/FAIL lines and the reported values.
3. The list of files created or changed.
4. Any MATLAB warnings and what was done about them.

If MATLAB cannot be launched, say so and do not claim the code was tested.
