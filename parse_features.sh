#!/bin/bash

## parse_features.sh
# Description: High-Performance Yeast Genomic Feature Extraction & ETL Pipeline
# Author: Rishit Maiti (Computer Science Major / Data Science and Biology Dual Minors)
# Date: 2026-08-23

## Design Philosophy: "Dead programs tell no lies" (Fail-fast bash orchestration)
# This script processes the Yeast Saccharomyces Genome Database (SGD) features
# file entirely in stream buffers, maintaining an O(1) memory footprint.


set -u          # Exit immediately if any unassigned variable is referenced
set -e          # Abort on the first non-zero exit status of any command
set -o pipefail # Propagate error statuses through pipes to catch intermediate failures

### Configuration & Styling 
BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
RED="\033[31m"
RESET="\033[0m"

### Argument Validation 
if [ $# -ne 1 ]; then
    echo -e "${RED}${BOLD}Error:${RESET} Missing required positional argument."
    echo -e "Usage: $0 <path_to_SGD_features.tab>"
    exit 1
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}${BOLD}Error:${RESET} Feature file not found at: $INPUT_FILE"
    exit 1
fi

if [ ! -r "$INPUT_FILE" ]; then
    echo -e "${RED}${BOLD}Error:${RESET} Feature file is not readable: $INPUT_FILE"
    exit 1
fi

### Main ETL Execution ###  
echo -e "${CYAN}================================================================${RESET}"
echo -e "${BOLD}🧬 GENOMIC FEATURE ANNOTATION PARSING PIPELINE 🧬${RESET}"
echo -e "${CYAN}================================================================${RESET}"
echo -e "Ingesting raw biological annotations from: ${BOLD}$INPUT_FILE${RESET}"
echo

# 1. Calculate Dataset Volume
echo -e "${GREEN}[1/4] Calculating database volume...${RESET}"
TOTAL_ROWS=$(wc -l < "$INPUT_FILE" | xargs)
echo -e "  -> Total Genomic Features Annotated: ${BOLD}${TOTAL_ROWS}${RESET}"
echo

# 2. Functional Classification Analysis
echo -e "${GREEN}[2/4] Profiling annotation validation categories (Column 3)...${RESET}"
# Column 3 lists whether a feature is "Verified", "Uncharacterized", or "Merged"
VERIFIED=$(cut -f 3 "$INPUT_FILE" | grep -c "^Verified$" || true)
UNCHARACTERIZED=$(cut -f 3 "$INPUT_FILE" | grep -c "^Uncharacterized$" || true)
MERGED=$(cut -f 3 "$INPUT_FILE" | grep -c "^Merged$" || true)

echo -e "  - ${BOLD}Verified Features:${RESET}       ${VERIFIED}"
echo -e "  - ${BOLD}Uncharacterized Features:${RESET} ${UNCHARACTERIZED}"
echo -e "  - ${BOLD}Merged Features:${RESET}          ${MERGED}"
echo

# 3. Strand Distribution Profile (Watson vs. Crick)
echo -e "${GREEN}[3/4] Parsing sequence strandedness (Column 12)...${RESET}"
# Column 12 contains 'W' for Watson (forward/plus) or 'C' for Crick (reverse/minus)
WATSON=$(cut -f 12 "$INPUT_FILE" | grep -c "^W$" || true)
CRICK=$(cut -f 12 "$INPUT_FILE" | grep -c "^C$" || true)

echo -e "  - ${BOLD}Watson (Forward) Strand [W]:${RESET} ${WATSON}"
echo -e "  - ${BOLD}Crick (Reverse) Strand [C]:${RESET}  ${CRICK}"
echo

# 4. Feature Taxonomy Profiling (Column 2)
echo -e "${GREEN}[4/4] Generating genomic feature taxonomy (Column 2)...${RESET}"
echo -e "${BOLD}Top 10 Most Prevalent Genomic Feature Classes:${RESET}"
echo -e "--------------------------------------------------------"
printf "${BOLD}%-10s  %-30s${RESET}\n" "Count" "Feature Type"
echo -e "--------------------------------------------------------"

# Stream pipeline: Extract Column 2, sort, count occurrences, sort descending, grab top 10
cut -f 2 "$INPUT_FILE" | sort | uniq -c | sort -rn | head -n 10 | awk '{
    count = $1;
    $1 = ""; # Remove the count from the print buffer
    gsub(/^ +| +$/, "", $0); # Strip trailing/leading spaces
    printf "%-10s  %-30s\n", count, $0;
}'
echo -e "--------------------------------------------------------"
echo

echo -e "${GREEN}SUCCESS:${RESET} Stream processing complete. Near-zero memory utilized."
echo -e "${CYAN}================================================================${RESET}"