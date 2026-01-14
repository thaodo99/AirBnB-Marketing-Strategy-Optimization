# Airbnb Market Analysis: Miami vs. Paris


## **Project Overview** 
- This project analyzes Airbnb markets in Miami and Paris using structured listing data and unstructured review text. Log-linear regression and LDA topic modeling are applied to identify key occupancy drivers and extract guest sentiment from reviews. The results reveal meaningful cross-market differences in pricing sensitivity, space preferences, host type effects, and guest feedback, which motivated our tailored, market-specific marketing recommendations.

- This was completed as a group collaboration with Liz Ji, Bella Liu, and Hamy Vu.


## 📌 **Objectives** 
- Identify key drivers of occupancy using regression modeling
- Extract and analyze guest review themes using NLP and topic modeling
- Compare demand dynamics across Miami and Paris
- Translate analytical findings into actionable marketing recommendations

## 📌 **Methodology**
### 1. Regression Analysis (Marketing Mix Modeling)
- Feature engineering, variable transformation, and multicollinearity checks 
- Log-linear regression on occupancy (last 90 days)
- Cross-market comparison of coefficients and explanatory power

### 2. Text & Sentiment Analysis
- Review preprocessing (tokenization, stopword removal, stemming)
- Sentiment scoring using dictionary-based NLP methods

### 3. Topic Modeling (LDA / STM)
- Topic extraction from guest reviews
- Identification of topics associated with high vs. low ratings
- Visualization via word clouds and topic–rating relationships

## 📌 **Key Insights**
- Occupancy is strongly driven by ratings, review sentiment, space, and entire-home listings
- Price and minimum-night sensitivity differs meaningfully across markets
- Miami guests value space and privacy more heavily while Paris guests prioritize host warmth, design, and flexible stays
- Professional hosts underperform in Paris, likely due to misalignment with guest expectations

## 📌 **Tools & Techniques**
- Language: R
- Modeling: Log-linear regression, interaction terms
- NLP: Sentiment analysis, LDA / Structural Topic Modeling
- Packages: sentimentr, syuzhet, tm, stm, wordcloud
