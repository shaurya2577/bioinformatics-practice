# Differential Gene Expression Analysis Pipeline

A comprehensive bioinformatics analysis pipeline for identifying differentially expressed genes between treatment and control conditions, with emphasis on data quality control, statistical rigor, and reproducible research practices.

**Author:** Shaurya Bhartia
**Email:** shaurya2577@berkeley.edu
**Date:** October 2025

---

## Table of Contents

- [Project Overview](#project-overview)
- [Key Features](#key-features)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Methodology](#methodology)
- [Results Interpretation](#results-interpretation)
- [Dependencies](#dependencies)
- [Future Enhancements](#future-enhancements)

---

## Project Overview

This project implements a complete differential expression analysis workflow designed to identify genes with significantly different expression levels between treatment and control conditions. The pipeline demonstrates fundamental bioinformatics skills including data quality control, statistical testing with multiple testing correction, professional data visualization, and reproducible analysis practices.

**Biological Context:**
Differential gene expression analysis is a cornerstone technique in cancer research and translational medicine. By identifying genes that are significantly up- or downregulated between conditions (e.g., tumor vs. normal, treated vs. untreated), researchers can uncover molecular biomarkers, therapeutic targets, and biological pathways involved in disease progression or treatment response.

**Analysis Scope:**
- 50 genes across 6 samples (3 treatment, 3 control)
- Gene expression quantification (RNA-seq count data)
- Statistical comparison using Student's t-test
- Multiple testing correction using Benjamini-Hochberg FDR
- Effect size calculation using Cohen's d

---

## Key Features

### 1. **Data Quality Control**
- Automated detection of missing values and data integrity checks
- Sample-level summary statistics (mean, median, standard deviation, coefficient of variation)
- Visual assessment of expression distributions across samples
- Identification of potential outliers or batch effects

### 2. **Statistical Rigor**
- Two-sample Student's t-test for each gene
- False Discovery Rate (FDR) correction using Benjamini-Hochberg method
- Effect size estimation using Cohen's d
- Significance thresholds: adjusted p-value < 0.05 and |log2 fold change| > 1

### 3. **Professional Visualization**
- **QC Boxplot:** Expression distribution across all samples
- **QC Density Plot:** Log2-transformed expression density for quality assessment
- **Volcano Plot:** Visualization of fold change vs. statistical significance
- **Expression Heatmap:** Hierarchical clustering of top differentially expressed genes
- Colorblind-friendly palettes throughout
- Publication-quality figures (300 DPI)

### 4. **Reproducibility**
- Organized project structure following best practices
- R project file for consistent working directory management
- Session information capture for computational environment documentation
- Clear code documentation and comments
- Parameterized analysis for easy adaptation to new datasets

---

## Project Structure

```
bioinformatics-practice/
├── README.md                                    # Project documentation
├── gene_expression_analysis.Rproj              # R project file
├── data/
│   └── mock_expression_data.csv                # Gene expression dataset (50 genes × 6 samples)
├── scripts/
│   └── differential_expression_analysis.R      # Main analysis pipeline
├── results/
│   ├── sample_qc_statistics.csv                # QC metrics per sample
│   ├── differential_expression_results.csv     # Full DE results with statistics
│   └── session_info.txt                        # R session information
└── figures/
    ├── qc_boxplot.png                          # Sample expression distributions
    ├── qc_density_plot.png                     # Expression density curves
    ├── volcano_plot.png                        # DE volcano plot
    └── expression_heatmap.png                  # Clustered heatmap of top genes
```

---

## Installation

### Prerequisites

1. **R** (version 4.0.0 or higher)
   - Download from [CRAN](https://cran.r-project.org/)
   - Installation instructions vary by operating system

2. **Required R Packages:**
   ```r
   install.packages(c("ggplot2", "dplyr", "tidyr", "pheatmap", "RColorBrewer"))
   ```

### Setup

1. Clone or download this repository:
   ```bash
   git clone <repository-url>
   cd bioinformatics-practice
   ```

2. Open the R project:
   - Double-click `gene_expression_analysis.Rproj` to open in RStudio
   - OR set working directory in R: `setwd("/path/to/bioinformatics-practice")`

3. Verify all required packages are installed:
   ```r
   required_packages <- c("ggplot2", "dplyr", "tidyr", "pheatmap", "RColorBrewer")
   missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
   if(length(missing_packages)) install.packages(missing_packages)
   ```

---

## Usage

### Running the Complete Analysis

From the project root directory, execute the analysis script:

```bash
Rscript scripts/differential_expression_analysis.R
```

Or from within R/RStudio:

```r
source("scripts/differential_expression_analysis.R")
```

### Expected Output

The analysis generates:
- **3 QC/results CSV files** in `results/`
- **4 publication-quality figures** in `figures/`
- **Console output** summarizing key findings
- **Session information** for reproducibility

**Runtime:** < 30 seconds on standard hardware

---

## Methodology

### 1. Data Import and Exploration

The analysis begins by loading the gene expression dataset, a CSV file containing:
- **Rows:** Individual genes (n = 50)
- **Columns:** Sample IDs with expression counts
- **Groups:** 3 treatment samples and 3 control samples

```r
# Data structure
gene_id  | sample1 | sample2 | sample3 | control1 | control2 | control3
---------|---------|---------|---------|----------|----------|----------
GENE001  | 245.3   | 289.1   | 267.8   | 198.4    | 205.7    | 192.3
...
```

### 2. Quality Control Checks

**Missing Value Detection:**
- Automated scan for NA or null values
- Report any data integrity issues

**Sample-Level Statistics:**
- Mean expression per sample
- Median expression (robust to outliers)
- Standard deviation (measure of variability)
- Coefficient of variation (CV = SD/mean × 100)

**Visual QC:**
- **Boxplots** reveal overall expression distributions and potential outliers
- **Density plots** assess whether samples have similar expression profiles
- Both visualizations help identify batch effects or sample quality issues

### 3. Data Preprocessing

**Log2 Transformation:**
```r
log2_expr <- log2(expression + 1)  # Pseudocount avoids log(0)
```

**Why log-transform?**
- RNA-seq data is typically right-skewed
- Log transformation stabilizes variance
- Makes data more normally distributed for t-tests
- Fold changes become symmetric (2-fold up = -2-fold down)

**Low Expression Filtering:**
- Filter genes with mean log2 expression < 4
- Removes noise from very lowly expressed genes
- Focuses analysis on reliably detected transcripts

### 4. Statistical Testing

For each gene, we test the null hypothesis: *"There is no difference in expression between treatment and control groups."*

**Test Used:** Two-sample Student's t-test (assumes equal variances)

**Multiple Testing Correction:**
When testing thousands of genes simultaneously, we expect some significant results by chance. The False Discovery Rate (FDR) controls the expected proportion of false positives among all significant findings.

- **Method:** Benjamini-Hochberg procedure
- **Interpretation:** An adjusted p-value (padj) < 0.05 means we expect < 5% of significant genes to be false positives

**Effect Size:**
Statistical significance doesn't always equal biological importance. Cohen's d quantifies the magnitude of difference:
```r
Cohen's d = (mean_treatment - mean_control) / pooled_SD
```
- Small effect: |d| ≈ 0.2
- Medium effect: |d| ≈ 0.5
- Large effect: |d| ≈ 0.8

### 5. Classification Criteria

Genes are classified as **differentially expressed** if they meet BOTH criteria:
1. **Statistical significance:** adjusted p-value < 0.05
2. **Biological significance:** |log2 fold change| > 1 (i.e., > 2-fold change)

**Categories:**
- **Upregulated:** log2FC > 1 and padj < 0.05 (higher in treatment)
- **Downregulated:** log2FC < -1 and padj < 0.05 (higher in control)
- **Not Changed:** Does not meet both criteria

### 6. Data Visualization

**Volcano Plot:**
- X-axis: log2 fold change (magnitude of change)
- Y-axis: -log10(p-value) (statistical significance)
- Highlights genes that are both significantly and substantially changed
- Dashed lines indicate significance thresholds

**Expression Heatmap:**
- Shows the top 20 most significant genes
- Colors represent z-scored expression (row-normalized)
- Hierarchical clustering groups similar genes and samples
- Reveals expression patterns across conditions

---

## Results Interpretation

### Output Files

**1. `sample_qc_statistics.csv`**
Contains per-sample QC metrics. Check for:
- Similar mean/median values across samples (consistency)
- Low coefficient of variation (good replicability)
- No extreme outliers

**2. `differential_expression_results.csv`**
Complete results table with columns:
- `gene_id`: Gene identifier
- `treatment_mean`, `control_mean`: Average log2 expression per group
- `log2FC`: Log2 fold change (Treatment/Control)
- `cohens_d`: Effect size
- `p_value`: Raw p-value from t-test
- `p_adjusted`: FDR-corrected p-value
- `significance`: "Significant" or "Not Significant"
- `regulation`: "Upregulated", "Downregulated", or "Not Changed"

**Key Questions to Ask:**
1. How many genes are significantly differentially expressed?
2. Are there more upregulated or downregulated genes?
3. Do the most significant genes have large effect sizes?
4. Which genes have the largest fold changes?

**3. `session_info.txt`**
Documents the computational environment for reproducibility:
- R version
- Package versions
- Operating system

### Figures

**QC Plots** (`qc_boxplot.png`, `qc_density_plot.png`):
- Assess data quality before analysis
- Ensure samples cluster by biological group, not batch

**Volcano Plot** (`volcano_plot.png`):
- Provides an overview of all tested genes
- Significant genes (colored) stand out from non-significant (grey)
- Genes in upper-left/right corners are most interesting (large FC + small p-value)

**Heatmap** (`expression_heatmap.png`):
- Validates that differentially expressed genes separate treatment from control
- Hierarchical clustering should group biological replicates together
- Clear visual confirmation of expression patterns

---

## Dependencies

This project uses the following R packages:

| Package | Version | Purpose |
|---------|---------|---------|
| **ggplot2** | ≥ 3.3.0 | Data visualization and plotting |
| **dplyr** | ≥ 1.0.0 | Data manipulation and transformation |
| **tidyr** | ≥ 1.1.0 | Data reshaping and tidying |
| **pheatmap** | ≥ 1.0.12 | Enhanced heatmap generation |
| **RColorBrewer** | ≥ 1.1-2 | Color palettes for visualizations |

**Installation:**
```r
install.packages(c("ggplot2", "dplyr", "tidyr", "pheatmap", "RColorBrewer"))
```

---

## Future Enhancements

This project establishes a strong foundation for bioinformatics analysis. Potential expansions include:

### Statistical Methods
- **Robust alternatives:** Implement Wilcoxon rank-sum test for non-normal data
- **Advanced DE tools:** Integrate DESeq2 or edgeR for more sophisticated modeling
- **Batch effect correction:** Add ComBat or RUVSeq for multi-batch experiments

### Biological Interpretation
- **Pathway analysis:** Test for enriched biological pathways using GSEA or Enrichr
- **Gene Ontology analysis:** Identify overrepresented functional categories
- **Network analysis:** Build gene co-expression networks to identify modules

### Visualization Enhancements
- **MA plot:** Alternative visualization showing log mean vs log fold change
- **PCA plot:** Principal component analysis to assess sample clustering
- **Interactive plots:** Use plotly for interactive exploration of results

### Data Integration
- **Multi-omic analysis:** Integrate genomic, epigenomic, or proteomic data
- **Clinical data:** Incorporate patient outcomes or clinical variables
- **Public datasets:** Apply pipeline to TCGA, GTEx, or GEO datasets

### Reproducibility
- **Docker containerization:** Package entire environment for platform independence
- **Snakemake/Nextflow:** Implement workflow management for scalability
- **RMarkdown report:** Generate automated HTML/PDF reports with embedded figures

---

## Learning Outcomes

This project demonstrates proficiency in:

✅ **R Programming:** Data import, manipulation with dplyr/tidyr, visualization with ggplot2
✅ **Statistical Analysis:** Hypothesis testing, multiple testing correction, effect sizes
✅ **Bioinformatics:** Gene expression analysis, differential expression workflows
✅ **Data QC:** Quality control checks, outlier detection, data validation
✅ **Visualization:** Publication-quality figures, effective communication of results
✅ **Reproducibility:** Project organization, documentation, session tracking
✅ **Version Control:** Git workflow with meaningful commit history
✅ **Scientific Communication:** Clear documentation of methods and interpretation

---

## References

- Anders, S., & Huber, W. (2010). Differential expression analysis for sequence count data. *Genome Biology*, 11(10), R106.
- Benjamini, Y., & Hochberg, Y. (1995). Controlling the false discovery rate: A practical and powerful approach to multiple testing. *Journal of the Royal Statistical Society: Series B*, 57(1), 289-300.
- Love, M. I., Huber, W., & Anders, S. (2014). Moderated estimation of fold change and dispersion for RNA-seq data with DESeq2. *Genome Biology*, 15(12), 550.
- Wickham, H. (2016). *ggplot2: Elegant Graphics for Data Analysis*. Springer-Verlag New York.

---

## Contact

**Shaurya Bhartia**
Email: shaurya2577@berkeley.edu
GitHub: [@shaurya2577](https://github.com/shaurya2577)

For questions about this analysis or potential collaborations, please reach out via email.

---

*This project was created to demonstrate bioinformatics and computational biology skills relevant to translational cancer research. The analysis pipeline follows best practices in reproducible research and is designed to be easily adapted for real-world gene expression datasets.*
