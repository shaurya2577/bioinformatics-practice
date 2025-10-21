################################################################################
# Differential Gene Expression Analysis
#
# Description: This script performs a comprehensive differential expression
# analysis comparing treatment vs control samples. The analysis includes:
# - Data quality control and preprocessing
# - Statistical testing with multiple testing correction
# - Professional data visualization
# - Reproducible results output
#
# Author: Shaurya Bhartia
# Email: shaurya2577@berkeley.edu
# Date: October 2025
################################################################################

# Load required packages -------------------------------------------------------
# Install packages if needed: install.packages(c("ggplot2", "dplyr", "tidyr", "pheatmap", "RColorBrewer"))
suppressPackageStartupMessages({
  library(ggplot2)   # Data visualization
  library(dplyr)     # Data manipulation
  library(tidyr)     # Data tidying
  library(pheatmap)  # Enhanced heatmaps
  library(RColorBrewer) # Color palettes
})

# Set up environment -----------------------------------------------------------
set.seed(123)  # For reproducibility

# Define color palette for colorblind accessibility
cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442",
               "#0072B2", "#D55E00", "#CC79A7")

# Create output directories if they don't exist
if (!dir.exists("results")) dir.create("results")
if (!dir.exists("figures")) dir.create("figures")

################################################################################
# STEP 1: DATA IMPORT
################################################################################

cat("Step 1: Importing data...\n")

# Import gene expression data
expression_data <- read.csv("data/mock_expression_data.csv",
                            stringsAsFactors = FALSE)

# Display data structure
cat("Dataset dimensions:", nrow(expression_data), "genes x",
    ncol(expression_data) - 1, "samples\n")
cat("First few rows:\n")
print(head(expression_data, 3))

################################################################################
# STEP 2: DATA QUALITY CONTROL
################################################################################

cat("\nStep 2: Performing quality control checks...\n")

# Check for missing values
missing_values <- sum(is.na(expression_data))
cat("Missing values:", missing_values, "\n")

# Prepare data for QC (reshape to long format)
qc_data <- expression_data %>%
  pivot_longer(cols = -gene_id,
               names_to = "sample",
               values_to = "expression") %>%
  mutate(group = ifelse(grepl("control", sample), "Control", "Treatment"))

# Calculate summary statistics per sample
sample_stats <- qc_data %>%
  group_by(sample, group) %>%
  summarise(
    mean_expr = mean(expression),
    median_expr = median(expression),
    sd_expr = sd(expression),
    cv = sd(expression) / mean(expression) * 100,
    .groups = "drop"
  )

cat("\nSample-level statistics:\n")
print(sample_stats)

# Export QC statistics
write.csv(sample_stats, "results/sample_qc_statistics.csv", row.names = FALSE)

# QC Visualization 1: Boxplot of expression distributions
cat("\nGenerating QC boxplot...\n")
p1 <- ggplot(qc_data, aes(x = sample, y = expression, fill = group)) +
  geom_boxplot(outlier.alpha = 0.3) +
  scale_fill_manual(values = c("Control" = cbPalette[2],
                                "Treatment" = cbPalette[1])) +
  labs(title = "Expression Distribution Across Samples",
       subtitle = "Quality Control Assessment",
       x = "Sample",
       y = "Expression Level (counts)",
       fill = "Group") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
        plot.title = element_text(face = "bold", size = 14),
        legend.position = "top")

ggsave("figures/qc_boxplot.png", p1, width = 8, height = 6, dpi = 300)
cat("Saved: figures/qc_boxplot.png\n")

# QC Visualization 2: Density plot
cat("Generating QC density plot...\n")
p2 <- ggplot(qc_data, aes(x = log2(expression + 1), color = sample,
                          linetype = group)) +
  geom_density(linewidth = 0.8) +
  scale_color_manual(values = rep(cbPalette, length.out = 6)) +
  labs(title = "Expression Density Distribution",
       subtitle = "Log2-transformed expression values",
       x = "Log2(Expression + 1)",
       y = "Density",
       color = "Sample",
       linetype = "Group") +
  theme_classic() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "right")

ggsave("figures/qc_density_plot.png", p2, width = 10, height = 6, dpi = 300)
cat("Saved: figures/qc_density_plot.png\n")

################################################################################
# STEP 3: DATA PREPROCESSING
################################################################################

cat("\nStep 3: Preprocessing data...\n")

# Separate gene IDs from expression values
gene_ids <- expression_data$gene_id
expr_matrix <- as.matrix(expression_data[, -1])
rownames(expr_matrix) <- gene_ids

# Log2 transformation (adding pseudocount to avoid log(0))
log2_expr <- log2(expr_matrix + 1)

# Calculate mean expression per gene
mean_expr_per_gene <- rowMeans(log2_expr)

# Filter low-expression genes (mean log2 expression > 4)
filter_threshold <- 4
expressed_genes <- mean_expr_per_gene > filter_threshold

cat("Genes before filtering:", nrow(expr_matrix), "\n")
cat("Genes after filtering (mean log2 > ", filter_threshold, "): ",
    sum(expressed_genes), "\n", sep = "")

# Apply filter
log2_expr_filtered <- log2_expr[expressed_genes, ]

################################################################################
# STEP 4: DIFFERENTIAL EXPRESSION ANALYSIS
################################################################################

cat("\nStep 4: Performing differential expression analysis...\n")

# Define sample groups
treatment_samples <- c("sample1", "sample2", "sample3")
control_samples <- c("control1", "control2", "control3")

# Calculate mean expression for each group
treatment_mean <- rowMeans(log2_expr_filtered[, treatment_samples])
control_mean <- rowMeans(log2_expr_filtered[, control_samples])

# Calculate log2 fold change (Treatment vs Control)
log2FC <- treatment_mean - control_mean

# Perform t-tests for each gene
p_values <- apply(log2_expr_filtered, 1, function(gene) {
  treatment_vals <- gene[treatment_samples]
  control_vals <- gene[control_samples]

  # Two-sample t-test
  t_test <- t.test(treatment_vals, control_vals, var.equal = TRUE)
  return(t_test$p.value)
})

# Apply FDR correction (Benjamini-Hochberg method)
p_adjusted <- p.adjust(p_values, method = "BH")

# Calculate Cohen's d (effect size)
cohens_d <- apply(log2_expr_filtered, 1, function(gene) {
  treatment_vals <- gene[treatment_samples]
  control_vals <- gene[control_samples]

  # Pooled standard deviation
  n1 <- length(treatment_vals)
  n2 <- length(control_vals)
  pooled_sd <- sqrt(((n1 - 1) * var(treatment_vals) +
                      (n2 - 1) * var(control_vals)) / (n1 + n2 - 2))

  # Cohen's d
  d <- (mean(treatment_vals) - mean(control_vals)) / pooled_sd
  return(d)
})

# Compile results
results <- data.frame(
  gene_id = rownames(log2_expr_filtered),
  treatment_mean = treatment_mean,
  control_mean = control_mean,
  log2FC = log2FC,
  cohens_d = cohens_d,
  p_value = p_values,
  p_adjusted = p_adjusted,
  stringsAsFactors = FALSE
)

# Classify genes based on significance and fold change thresholds
results <- results %>%
  mutate(
    significance = case_when(
      p_adjusted < 0.05 & abs(log2FC) > 1 ~ "Significant",
      TRUE ~ "Not Significant"
    ),
    regulation = case_when(
      p_adjusted < 0.05 & log2FC > 1 ~ "Upregulated",
      p_adjusted < 0.05 & log2FC < -1 ~ "Downregulated",
      TRUE ~ "Not Changed"
    )
  ) %>%
  arrange(p_adjusted)

# Summary statistics
cat("\nDifferential Expression Summary:\n")
cat("Significance thresholds: p_adjusted < 0.05, |log2FC| > 1\n")
summary_table <- results %>%
  group_by(regulation) %>%
  summarise(count = n(), .groups = "drop")
print(summary_table)

# Export results
write.csv(results, "results/differential_expression_results.csv",
          row.names = FALSE)
cat("\nSaved: results/differential_expression_results.csv\n")

################################################################################
# STEP 5: VISUALIZATION OF RESULTS
################################################################################

cat("\nStep 5: Creating visualizations...\n")

# Visualization 1: Volcano Plot
cat("Generating volcano plot...\n")

# Add -log10(p-value) for plotting
results <- results %>%
  mutate(neg_log10_p = -log10(p_value))

p3 <- ggplot(results, aes(x = log2FC, y = neg_log10_p, color = regulation)) +
  geom_point(alpha = 0.6, size = 2.5) +
  scale_color_manual(values = c("Upregulated" = cbPalette[1],
                                 "Downregulated" = cbPalette[2],
                                 "Not Changed" = "grey60")) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed",
             color = "grey30", linewidth = 0.5) +
  geom_vline(xintercept = c(-1, 1), linetype = "dashed",
             color = "grey30", linewidth = 0.5) +
  labs(title = "Volcano Plot: Treatment vs Control",
       subtitle = paste("Upregulated:", sum(results$regulation == "Upregulated"),
                        "| Downregulated:", sum(results$regulation == "Downregulated")),
       x = "Log2 Fold Change (Treatment/Control)",
       y = "-Log10(p-value)",
       color = "Regulation") +
  theme_classic() +
  theme(plot.title = element_text(face = "bold", size = 14),
        legend.position = "top")

ggsave("figures/volcano_plot.png", p3, width = 8, height = 7, dpi = 300)
cat("Saved: figures/volcano_plot.png\n")

# Visualization 2: Heatmap of top differentially expressed genes
cat("Generating expression heatmap...\n")

# Select top genes by adjusted p-value
top_genes <- results %>%
  filter(significance == "Significant") %>%
  arrange(p_adjusted) %>%
  head(20) %>%
  pull(gene_id)

if(length(top_genes) > 0) {
  # Prepare data for heatmap
  heatmap_data <- log2_expr_filtered[top_genes, ]

  # Scale by row (z-score) for better visualization
  heatmap_data_scaled <- t(scale(t(heatmap_data)))

  # Create annotation for samples
  annotation_col <- data.frame(
    Group = c(rep("Treatment", 3), rep("Control", 3)),
    row.names = colnames(heatmap_data_scaled)
  )

  # Define colors for annotation
  annotation_colors <- list(
    Group = c("Treatment" = cbPalette[1], "Control" = cbPalette[2])
  )

  # Generate heatmap
  png("figures/expression_heatmap.png", width = 8, height = 10,
      units = "in", res = 300)

  pheatmap(heatmap_data_scaled,
           color = colorRampPalette(rev(brewer.pal(11, "RdBu")))(100),
           clustering_distance_rows = "euclidean",
           clustering_distance_cols = "euclidean",
           clustering_method = "complete",
           annotation_col = annotation_col,
           annotation_colors = annotation_colors,
           show_rownames = TRUE,
           show_colnames = TRUE,
           fontsize = 10,
           fontsize_row = 8,
           main = "Top 20 Differentially Expressed Genes\n(Z-score normalized)")

  dev.off()
  cat("Saved: figures/expression_heatmap.png\n")
} else {
  cat("No significant genes found for heatmap\n")
}

################################################################################
# STEP 6: SESSION INFO FOR REPRODUCIBILITY
################################################################################

cat("\nStep 6: Saving session information...\n")

# Capture session information
session_file <- "results/session_info.txt"
writeLines(capture.output(sessionInfo()), session_file)
cat("Saved: results/session_info.txt\n")

################################################################################
# ANALYSIS COMPLETE
################################################################################

cat("\n" , rep("=", 80), "\n", sep = "")
cat("Analysis complete!\n")
cat("Results saved to: results/\n")
cat("Figures saved to: figures/\n")
cat(rep("=", 80), "\n", sep = "")
