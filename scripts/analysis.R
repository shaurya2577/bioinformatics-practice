# Gene Expression Analysis Script
# Differential expression analysis with statistical testing

# Load data
data <- read.csv("../data/mock_expression_data.csv", row.names = 1)

# Calculate means
control_means <- rowMeans(data[, 1:3])
treatment_means <- rowMeans(data[, 4:6])

# Calculate fold change and log2 fold change
fold_change <- treatment_means / control_means
log2_fc <- log2(fold_change)

# Perform t-tests for each gene
p_values <- apply(data, 1, function(row) {
  control <- row[1:3]
  treatment <- row[4:6]
  t.test(treatment, control)$p.value
})

# Create results dataframe
results <- data.frame(
  Gene = rownames(data),
  Control_Mean = control_means,
  Treatment_Mean = treatment_means,
  Fold_Change = fold_change,
  Log2FC = log2_fc,
  P_Value = p_values
)

# Display results
print("Differential Expression Results:")
print(results)

# Display significant genes (p < 0.05)
sig_genes <- results[results$P_Value < 0.05, ]
print(paste("\nSignificant genes:", nrow(sig_genes)))
