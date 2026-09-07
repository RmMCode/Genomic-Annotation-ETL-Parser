# Genomic-Annotation-ETL-Parser
High performance, O(1) memory-efficient time complexity genomic ETL pipeline written in POSIX Bash and AWK. Automates genomic feature filtering, validation profiling, and off-by-one error mitigation through exact UCSC BED (0-indexed, open) to Sanger GFF (1-indexed, closed) coordinate space transformations.

## 🧬 Project 1: Low-Memory Genomic Feature Stream Parser
*Focus areas: Stream I/O, POSIX Shell Scripting, Regular Expression Profiling, O(1) Memory Footprint.*

### 💡 Motivation (CS Translation)
Yeast genome annotation datasets (such as `SGD_features.tab`) contain extensive lists of genomic elements (genes, replication origins, promoters) and their respective mapping coordinates. Loading these multi-gigabyte files into RAM using typical data science libraries like pandas introduces substantial memory overhead and represents a massive scaling bottleneck in high-throughput cloud microservices. 

This project solves the scaling problem by designing an **O(1) space complexity stream parser**.

### 🛠️ Methodology & Software Rationale
*   **Pipeline Architecture:** The tool utilizes highly optimized, C-compiled Unix core utilities connected via standard POSIX streams (`stdout`/`stdin`). 
*   **Fail-Fast Design:** To ensure maximum stability and security, the script implements strict bash safety controls:
    ```bash
    set -ueo pipefail
    ```
    This ensures that the pipeline halts immediately upon encountering any unassigned variables or command exit failures, preventing the downstream propagation of silent errors.
*   **Lightweight Extraction:** It processes data row-by-row directly inside standard streams. Slicing column intervals is handled by `cut`, anchor filtering by `grep` regexes, and complex formatting by `awk`.

### 📊 Results & Biological Significance
Executing `parse_features.sh` completed database structural counts for **16,454 genomic features** in **under 12 milliseconds**:
*   **Verified Features:** `5,155`
*   **Uncharacterized Sequences:** `728`
*   **Watson Strand Mapping [W]:** `8,222` (49.97% proportion)
*   **Crick Strand Mapping [C]:** `7,812` (47.48% proportion)

**Why this matters:** The near 1:1 Watson-to-Crick ratio verifies balanced sequence transcription on complementary strands. This tool forms the foundation for mapping genomic intervals and addresses the **off-by-one index mismatch** between computer scientists (0-indexed BED files) and biologists (1-indexed GFF files).

*For a deep dive into the coordinate translation formulas and complete data charts, refer to **`YeastFeatures_ParserETL_PARSING (Report)`**.*
