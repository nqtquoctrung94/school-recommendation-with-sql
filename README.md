# School Recommendation with SQL
This project aims to resolve the problem of choosing the best school based on the conditions:
- Must be in urban area
- top city ranking
- lowest crime rate
- must have the target course

# Tools
Azure Data Studio was used to load the data and generated SQL query for this project

# Files
The files are organized as below:
- `input files` folder contains all the original files
- `cleaned files` folder contains the files that are cleaned in excel and loaded into Azure Data Studio
- `Questions.pdf` contains the questions in Vietnamese for this project
- `University_recommendation.sql` is the final query to answer the questions "Which are the best schools for Robert based on his conditions?". The some advance methods was used to answer this question are:
  - CTE
  - PERCENTILE_CONT()
  - DENSE_RANK()
  - sum of ranks and order by lowest total rank sum
