######################
# Sentiment Analysis #
######################

## Install Packages (if needed)

install.packages("sentimentr")
install.packages("syuzhet")
install.packages("tm")


## Load Packages and Set Seed

library(sentimentr)
library(syuzhet)
library(tm)
set.seed(1)

## Read in the Listings and Reviews Data

listings <- read.csv(file.choose()) ## Choose Miami_listings.csv
reviews <- read.csv(file.choose()) ## Choose or Miami_reviews.csv

## Run if Mac
reviews$comments <- iconv(reviews$comments, to = "utf-8-mac")

## Process reviews for sentiment analysis

text <- VCorpus(VectorSource(reviews$comments))
text <- tm_map(text, stripWhitespace)
text <- tm_map(text, content_transformer(tolower))
text <- tm_map(text, removeWords, stopwords("english"))
text <- tm_map(text, stemDocument)
sentiment <- get_sentiment(text$content, method="syuzhet")

## Add sentiment score to listings file

listings$sentiment <- sentiment

#################
# Marketing Mix #
#################

## Look at means of variables

lapply(sapply(listings,mean),round,2)

## Check for multicollinearity - 4 'size-related' variables only

cor_vars <- c ("accommodates", "bedrooms", "bathrooms", "beds")
cor_data <- listings[cor_vars]
cor_table <- cor(cor_data)
round(cor_table,2)

# Check for multicollinearity - all variables
numeric_vars <- sapply(listings, is.numeric)
cor_table_all <- cor(listings[, numeric_vars], use = "pairwise.complete.obs")
round(cor_table_all, 2)

write.table(round(cor_table_all, 2),
            sep = "\t",
            row.names = TRUE,
            col.names = NA) # for gsheet format only

## Check skewness

vars <- c("occupancy", "price", "number_of_reviews", "rating", 
          "accommodates", "minimum_nights", "bedrooms", 
          "bathrooms", "beds", "host_is_superhost", 
          "pro_host", "entire_home", "instant_bookable", 
          "sentiment")

par(mfrow = c(4, 4))   # 4x4 grid of plots

for (v in vars) {
  x <- listings[[v]]
  
  hist(x,
       main = paste("Histogram of", v),
       xlab = v,
       freq = FALSE,
       col = "lightgray",
       border = "white")
  
  lines(density(x, na.rm = TRUE), lwd = 2)
}

par(mfrow = c(1,1))  # reset layout


## Run the regression - full model

miami_reg <- lm(log(occupancy+1) ~ log(price) + log(number_of_reviews+1) + rating +
                  log(accommodates) + log(bedrooms+1) + log(bathrooms+1) + log(beds+1) + log(minimum_nights+1) + host_is_superhost + 
                  pro_host + entire_home + instant_bookable + sentiment, data = listings)
summary(miami_reg)

## Thao's note: add log to all bed, bedrooms, bathrooms to be consistent with accommodate. + 1 for bath/bed/bedrooms as they have 0 values
## Run the regression - final model 

miami_reg_new <- lm(log(occupancy+1) ~ log(price) + log(number_of_reviews+1) + rating +
                      log(accommodates) + log(minimum_nights+1) + pro_host 
                    + entire_home + instant_bookable + sentiment + log(minimum_nights+1)*pro_host, data = listings)
summary(miami_reg_new)


### Note for team:
# remove: bed, bedrooms, bathrooms due to multicollinearity
# remove: host_is_superhost (statistically insignificant in Paris model)
# add: interaction effect between minimum nights and pro_host. 
    # This explains: increasing minimum-night requirements doesn't hurt occupancy as much as it does for regular hosts


#############################
# Structural Topic Modeling #
#############################

## Install Packages (if needed)

install.packages("stm")
install.packages("tm")
install.packages("Rtsne")
install.packages("rsvd")
install.packages("geometry")
install.packages("SnowballC")
install.packages("wordcloud")

## Load Packages and Set Seed

library(stm)
library(tm)
library(Rtsne)
library(rsvd)
library(geometry)
library(SnowballC)
library(wordcloud)
set.seed(1)

reviews$rating <- listings$rating

## Run if Mac
reviews$comments <- iconv(reviews$comments, to = "utf-8-mac")

## Process Documents

customwords = c("Airbnb", "Paris", "paris", "Miami", "miami")
processed <- textProcessor(reviews$comments, metadata = reviews, 
    customstopwords=customwords)
out <- prepDocuments(processed$documents, processed$vocab, processed$meta)
docs <- out$documents
vocab <- out$vocab
meta <- out$meta

## Determine Number of Topics (Takes Significant Time)

reviewsFit <- stm(documents = out$documents, vocab = out$vocab, K = 0, seed = 1,
  prevalence =~ rating, data = out$meta, init.type = "Spectral")

## See how many topics

num_topics <- reviewsFit$settings$dim$K
num_topics

## See which topics relate to high vs. low ratings

out$meta$rating <- as.factor(out$meta$rating)
prep <- estimateEffect(1:num_topics ~ rating, reviewsFit, meta=out$meta, 
     uncertainty="Global")
plot(prep, covariate="rating", topics=c(1:num_topics), model=reviewsFit, 
     method="difference", cov.value1=5, cov.value2=3,
     xlab="Lower Rating ... Higher Rating", main="Relationship between Topic and Rating",
     labeltype ="custom", custom.labels=c(1:num_topics))

## Visualize Topics
## Replace X with topic number you want to generate a word cloud for

## Positive Topics - Top 3

cloud(reviewsFit, topic=X)
cloud(reviewsFit, topic=37)   # homey, cozy, family feel
cloud(reviewsFit, topic=74)   # not useful
cloud(reviewsFit, topic=50)   # space: clean, quiet, private neighborhood
cloud(reviewsFit, topic=28)   # great location: close to beach, bar, restaurant, downtown, night life

## Negative Topics - Bottom 3

cloud(reviewsFit, topic=X)
cloud(reviewsFit, topic=67)   # haven't checked
cloud(reviewsFit, topic=66)  # haven't checked
cloud(reviewsFit, topic=47)  # communication issue
cloud(reviewsFit, topic=35)  # different from description
cloud(reviewsFit, topic=15)  # inconvenient: poor wifi
