AML.anno.filenames <- list.files("path/to/anno", full.names = TRUE, pattern="_AML.*anno.*txt.gz$")[1:35]

# Initialize an empty list to store cell IDs
cell_id_list <- list()

# Loop through each file and extract cell IDs with 'MutTranscripts' as 'mutant'
for (i in 1:length(AML.anno.filenames)) {
  # Read the file
  anno_data <- read.delim(AML.anno.filenames[i], header = TRUE, na.strings = "")

  # Filter the rows where 'MutTranscripts' is 'mutant'
  mutant_cells <- anno_data %>% filter(MutTranscripts != "normal") %>% select(Cell)
  # Store the cell IDs in the list
  cell_id_list[[i]] <- mutant_cells$Cell
  
  # Optionally print the cell IDs for each file to verify
  print(paste("File:", AML.anno.filenames[i]))
}

# Check the collected cell IDs across all files
str(cell_id_list)

# Optionally, you can flatten the list to create a single vector of all mutant cell IDs
all_mutant_cells <- unlist(cell_id_list)
print(all_mutant_cells)
length(all_mutant_cells)


# 필요한 라이브러리 로드
library(dplyr)

# Cell ID 리스트 (cell_id_list에 cell IDs가 저장되어 있다고 가정)
# cell_id_list <- c(...)  # 이미 생성된 cell_id_list를 사용

# 디렉토리 내의 .RData 파일 리스트
rdata_files <- list.files("path/to, 
                          full.names = TRUE, pattern = "^GSM.*_AML.*\\.star\\.expr\\.RData$"

)
rdata_files 

# cell_id_list가 리스트일 경우 벡터로 변환
cell_id_vector <- unlist(cell_id_list)
cell_id_vector

# cell_id_vector에서 하이픈을 마침표로 변환
modified_cell_id_vector <- gsub("-", ".", cell_id_vector)

# df와 df.stats 초기화
df <- data.frame()
df.stats <- data.frame()

# .RData 파일을 하나씩 처리하는 루프
for (rdata_file in rdata_files) {
  # RData 파일 로드 (d라는 데이터프레임이 로드된다고 가정)
  load(rdata_file)
  
  # 'd'에서 해당하는 cell ID만 필터링
  print(rdata_file)
  print(dim(d))
  
  # cell_id_vector에서 하이픈을 마침표로 변환
  modified_cell_id_vector <- gsub("-", ".", cell_id_vector)
  
  # 'd'에서 해당하는 cell ID만 필터링
  filtered_data <- d %>%
    select(any_of(modified_cell_id_vector))
  
  # 필터링된 데이터를 df에 추가
  if (ncol(filtered_data) > 0) {  # 필터링된 데이터가 비어있지 않은 경우
    if (nrow(df) == 0) {
      df <- filtered_data  # df가 비어있을 경우 filtered_data를 df로 설정
    } else {
      df <- bind_cols(df, filtered_data)  # 기존 df와 결합
    }
  }
  
  # d.stats 필터링
  filtered_d_stats <- d.stats %>%
    filter(rownames(d.stats) %in% modified_cell_id_vector)
  
  # 필터링된 d.stats를 df.stats에 추가 (행으로 추가)
  if (nrow(filtered_d_stats) > 0) {  # 필터링된 d.stats가 비어있지 않은 경우
    df.stats <- bind_rows(df.stats, filtered_d_stats) 
  }
}

# 결합된 데이터 확인
print(dim(df))
print(head(df))

# 최종 데이터를 df와 df.stats에 저장
d <- df
d.stats <- df.stats

# 최종 데이터를 AMLmut923cells.RData로 저장
save(d, file = "/home/song7602/3.workbench/RData/AMLmut923cells.RData")
