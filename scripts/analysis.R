# Gene Expression Analysis Script
# Basic differential expression analysis

# Load data
data <- read.csv("../data/mock_expression_data.csv", row.names = 1)

# Calculate means
control_means <- rowMeans(data[, 1:3])
treatment_means <- rowMeans(data[, 4:6])

# Calculate fold change
fold_change <- treatment_means / control_means

# Display results
print("Fold Changes:")
print(fold_change)
