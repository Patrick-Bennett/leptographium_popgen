# Filtering VCF script
args = commandArgs(trailingOnly=TRUE)

library(vcfR)
# Reading in file
vcf.name <- basename(args)
cat(paste0("Reading file ", vcf.name,"\n"))
vcf <- read.vcfR(args)

# Calculating raw number of sites
raw.vcf <- nrow(vcf)

# Calculating the number of polymorphic sites
vcf <- vcf[is.polymorphic(vcf, na.omit = T)]
poly.vcf <- nrow(vcf)

# Filtering

unfiltered.df <- NULL
dp_filter.df <- NULL
min_dp_filter.df <- NULL
mq.df <- NULL
maf.df <- NULL
miss.df <- NULL
mask.all <- list()
gt.vc <- list()


# Filtering
## Generating DP and GT matrices
cat("Generating DP and GT matrices\n")
dp.vc <- extract.gt(vcf, element = "DP", as.numeric = T)
gt.vc <- extract.gt(vcf, element = "GT", as.numeric = T)

## dp.vc backup
dp.vc.bk <- dp.vc
gt.vc.bk <- gt.vc

#####
# Step 1
# Filtering by DP (DP ranges (5% < x > 95%))
cat("Step 1: Filtering by DP quantiles\n")
## Creating quantiles based in the lower 5% and the higher 95%
sums <- apply(dp.vc, 2, function (x) quantile(x, probs=c(0.05, 0.50, 0.95), na.rm = T))
dp.all.2 <- sweep(dp.vc, MARGIN=2, FUN="-", sums[1,])
dp.vc[dp.all.2 <= 0] <- NA
dp.all.2 <- sweep(dp.vc, MARGIN=2, FUN="-", sums[3,])
dp.vc[dp.all.2 > 0] <- NA

## Creating a mask
dp.df <- dp.vc
## Mask based in depth
mask.dp.1 <- (apply(is.na(dp.vc), 1, sum) == ncol(dp.vc)) == F
### Maks based in polymorphisms
gt.vc[is.na(dp.df)] <- NA
mask.dp.2 <- lapply(apply(gt.vc, 1, unique), function (y) length(na.exclude(y))) != 1
mask.dp <- (mask.dp.1 * mask.dp.2) == 1
#
#####

#####
# Step 2
# Filtering by minimum DP (10x)
cat("Step 2: Based on minimum DP (DP > 10)", sep = "\n")
## Filtering by min DP
dp.df[dp.df < 10] <- NA
## Creating a mask
mask_min.dp.1 <- (apply(is.na(dp.df), 1, sum) == ncol(dp.df)) == F
### Maks based in polymorphisms
gt.vc[is.na(dp.df)] <- NA
mask_min.dp.2 <- lapply(apply(gt.vc, 1, unique), function (y) length(na.exclude(y))) != 1
mask_min.dp <- (mask_min.dp.1 * mask_min.dp.2) == 1
#
#####

#####
# Step 3
# Filtering by maximum MQ (MQ == 50)
## Reminder:
## Extracting the MQ information for all VCF objects
cat("Step 3: Based on MQ", sep = "\n")
mq <- extract.info(vcf, element = "MQ", as.numeric = T)
## Creating mask
mask.mq <- rep(T, nrow(vcf))
## Filtering in the mast
mask.mq[mq < 50] <- F
#
#####

#####
# Step 4
# Filtering on MAF
cat("Step 4: Filtering on MAF (Allele present in at least 2 individuals)", sep = "\n")
maf.tresh <- 2/(ncol(vcf@gt[,-1]))
cat("MAF threshold:", maf.tresh, "\n")
## Creating mast
library(stringr)
mask.maf <- rep(T, nrow(vcf))
## Extracting GT info and calculating MAF
class(gt.vc) <- 'numeric'
mask.maf <- apply(gt.vc, 1, function (x) min(table(x)))/ncol(vcf@gt) >= maf.tresh
#
#####

#####
# Step 5
# Filtering by missing data
cat("Step 5: Based on missing data (> 20% missing data)\n")
## Filtering by Missigness
mask.miss <- rep(T, nrow(vcf))
mask.miss <- apply(gt.vc, 1, function (x) sum(is.na(x))/ncol(gt.vc)) <= 0.20
#
#####

#####
# Saving all masks
mask.vcf <- cbind(mask.mq, mask.maf, mask.miss)
#
#####

filtered.vcf <- vcf[apply(mask.vcf, 1, sum) == 3,]
#filtered.gt <- gt.vc[apply(mask.vcf, 1, sum) == 3,]
#filtered.dp <- dp.vc[apply(mask.vcf, 1, sum) == 3,]

#filtered.gt.obj <- matrix(paste(filtered.gt, filtered.dp, sep = ":"), nrow(filtered.gt),ncol(filtered.gt))

#filtered.vcf@gt[,-1] <- filtered.gt.obj
#filtered.vcf@gt[,1] <- rep("GT:DP",times=length(filtered.vcf@gt[,1]))

fil.vcf <- nrow(filtered.vcf)
if (nrow(filtered.vcf) > 0 ){
write.vcf(filtered.vcf, file = paste0("filteredVCF/", vcf.name), mask = F)
} else {
  cat("No variants passed the filters.\n")
}

cbind(vcf.name, raw.vcf, poly.vcf, fil.vcf)
