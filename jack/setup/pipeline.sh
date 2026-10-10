#!/bin/bashl

source ./config.txt

if [[ "$MODE" != "interactive" && "$MODE" != "quiet" ]]; then
    printf 'MODE is not set to interactive or quiet - defaulting to quiet mode.\n' >&2
    MODE="quiet"
fi

mkdir -p "$WORK_DIR"

RUN_ID=$(date '+%Y%m%d_%H%M%S')
REPORT_DIR="$WORK_DIR/reports/$RUN_ID"
mkdir -p "$REPORT_DIR"
QUALITY_REPORT="$REPORT_DIR/quality_report.md"

if [[ "$MODE" == "interactive" ]]; then
    printf '\n\033[1;33mInitialising pipeline'
    for dot in 1 2 3 4 5; do
        sleep 0.2
        printf '.'
    done
    printf '\033[0m\n'

    printf '\n\033[1;36m'
    printf '%s\n' \
        '--------------------------------------------------' \
        '  01 — INPUT CHECKS AND EXPERIMENTAL COMPARISONS' \
        '--------------------------------------------------'
    printf '\033[0m\n'
fi

{
    printf '# Input validation and sequencing quality report\n\n'
    printf 'Run date: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf '## Input checks and planned comparisons\n\n```\n'
} > "$QUALITY_REPORT"

# Generate groups and comparisons.
if [[ "$MODE" == "interactive" ]]; then
    bash ./scripts/prepare_comparisons.sh \
        "$METADATA_FILE" "$WORK_DIR" "$FASTQ_DIR" |
        tee -a "$QUALITY_REPORT"
else
    bash ./scripts/prepare_comparisons.sh \
        "$METADATA_FILE" "$WORK_DIR" "$FASTQ_DIR" \
        >> "$QUALITY_REPORT"
fi

# Check the expected sequencing filenames.
if [[ "$MODE" == "interactive" ]]; then
    bash ./scripts/check_input_files.sh \
        "$METADATA_FILE" "$WORK_DIR" "$FASTQ_DIR" |
        tee -a "$QUALITY_REPORT"
else
    bash ./scripts/check_input_files.sh \
        "$METADATA_FILE" "$WORK_DIR" "$FASTQ_DIR" \
        >> "$QUALITY_REPORT"
fi

printf '\n```\n\n## FastQC results\n\n```text\n' \
    >> "$QUALITY_REPORT"

if [[ "$MODE" == "interactive" ]]; then
    printf '\n\033[1;32m✅ Input checks and comparison preparation complete.\033[0m\n'
    printf 'Press Enter to continue to FastQC, or Ctrl+C to stop: '
    read
    printf '\n'
fi

if [[ "$MODE" == "interactive" ]]; then
    printf '\n\033[1;36m'
    printf '%s\n' \
        '--------------------------------------------------' \
        '  02 — SEQUENCING QUALITY: FASTQC' \
        '--------------------------------------------------'
    printf '\033[0m\n'
fi

if [[ "$MODE" == "interactive" ]]; then
    bash ./scripts/fastqc.sh \
        "$FASTQ_DIR" "$WORK_DIR" "$THREADS" \
        "$METADATA_FILE" "$MODE" |
        tee -a "$QUALITY_REPORT"
else
    bash ./scripts/fastqc.sh \
        "$FASTQ_DIR" "$WORK_DIR" "$THREADS" \
        "$METADATA_FILE" "$MODE" \
        >> "$QUALITY_REPORT"
fi

{
    printf '\n```\n\n'
    printf 'Input checks and FastQC collection completed successfully.\n\n'
} >> "$QUALITY_REPORT"

if [[ "$MODE" == "interactive" ]]; then
    printf '\n\033[1;32m✅ Input checks and FastQC collection complete.\033[0m\n'
fi

printf 'Report saved at: %s\n' "$QUALITY_REPORT"


if [[ "$MODE" == "interactive" ]]; then
    printf '\nPress Enter to continue to quality assessment: '
    read
fi



