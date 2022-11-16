library(readxl)
dp_deseti <- read_xlsx("2021_10.xlsx")
dp_jedanest <- read_xlsx("2021_11.xlsx")
dp_dvanesti <- read_xlsx("2021_12.xlsx")
dd_prvi <- read_xlsx("2022_01.xlsx")
dd_drugi <- read_xlsx("2022_02.xlsx")
dd_treci <- read_xlsx("2022_03.xlsx")
dd_cet <- read_xlsx("2022_04.xlsx")
dd_pet <- read_xlsx("2022_05.xlsx")
dd_sesti <- read_xlsx("2022_06.xlsx")
dd_sedmi <- read_xlsx("2022_07.xlsx")
dd_osmi <- read_xlsx("2022_08.xlsx")
dd_deveti <- read_xlsx("2022_09.xlsx")
dd_deseti <- read_xlsx("2022_10.xlsx")

#install.packages("rlang")
#library(rlang)

library(tidyverse)
library(dplyr)

#df_list <- list(dp_deseti, dp_jedanest, dp_dvanesti, dd_prvi, dd_drugi, dd_treci, dd_cet, dd_pet, dd_sesti, dd_sedmi, dd_osmi, dd_deveti, dd_deseti)
#
dp_deseti <- dp_deseti %>% rename(ride_time = ride_lenght)

last_12_months <- union_all(dp_deseti, dp_jedanest, dp_dvanesti, dd_prvi, dd_drugi, dd_treci, dd_cet, dd_pet, dd_sesti, dd_sedmi, dd_osmi, dd_deveti, dd_deseti)

last_12_months %>% group_by(member_casual) %>% count(member_casual) 

####################################33
last_12_months_all <- union_all(dp_deseti, dp_jedanest, dp_dvanesti, dd_prvi, dd_drugi, dd_treci, dd_cet, dd_pet, dd_sesti, dd_sedmi, dd_osmi, dd_deveti, dd_deseti)

last_12_months_all$ride_hours <- format(as.POSIXct(last_12_months_all$ride_time), format = "%H")
last_12_months_all$ride_hours  <- as.numeric(last_12_months_all$ride_hours)
#last_12_months_all$ride_hours[last_12_months_all$ride_hours>0]
last_12_months_all$ride_hours <- last_12_months_all$ride_hours * 60 * 60


last_12_months_all$ride_min <- format(as.POSIXct(last_12_months_all$ride_time), format = "%M")
last_12_months_all$ride_min <- as.numeric(last_12_months_all$ride_min)
last_12_months_all$ride_min <- last_12_months_all$ride_min*60
last_12_months_all$ride_time <- format(as.POSIXct(last_12_months_all$ride_time), format = "%S")
last_12_months_all$ride_time <- as.numeric(last_12_months_all$ride_time)
last_12_months_all$ride_time <- last_12_months_all$ride_time + last_12_months_all$ride_min + last_12_months_all$ride_hours 
last_12_months_all$ride_min <- NULL
last_12_months_all$ride_time <- last_12_months_all$ride_time/60

last_12_months_all <- last_12_months_all[last_12_months_all$ride_time != 0,]

ggplot(last_12_months_all) + aes(x = ride_time) + geom_histogram(aes(fill = member_casual )) + ggtitle("Ride Time - Member vs. Casual")




last_12_months_all  %>% group_by(member_casual) %>% summarise(mean(ride_time), max(ride_time), mean(day_of_week), min(ride_time))

last_12_months_all  %>% group_by(member_casual, day_of_week) %>% summarise(mean_time_minutes = mean(ride_time), 
                                                            max_ride_time_minutes = max(ride_time), 
                                                            Min_ride_time_minutes = min(ride_time)) %>% arrange(-mean_time_minutes)

zaplot <- last_12_months_all  %>% group_by(member_casual, day_of_week) %>% summarise(mean_time = mean(ride_time), max(ride_time), min(ride_time)) %>% 
  arrange(-mean_time)

ggplot(zaplot) + aes(y=mean_time, x = day_of_week) + geom_point(aes(color = member_casual, shape = member_casual), size = 3) + 
  labs(title = "Average ride time by day of the week", subtitle = "Casual Vs. Member") + xlab("Day od the week (7-Sunday, 1-Saturday)") + ylab("Average ride time")

last_12_months_all %>% group_by(day_of_week, member_casual) %>% count(day_of_week) %>% arrange(-n) %>% 
  ggplot(aes(x=day_of_week, y=n)) + geom_point(aes(color= member_casual), size = 3) + labs(title = "Total rides by day of the week", subtitle = "Casual Vs. Member") +
  ylab("Total amount of rides") + theme(plot.title = element_text(hjust = 0.5, color = "black"), plot.subtitle = element_text(hjust = 0.5, color = "black"))


last_12_months_all %>% group_by(rideable_type, member_casual) %>% count(rideable_type) %>% arrange(-n) %>% ggplot(aes(x=rideable_type, y=n)) +
  geom_point(aes(color = member_casual,shape=member_casual), size = 3) + xlab("Type of bike") + ggtitle("Type of bike by user type") +
  theme(plot.title = element_text(hjust = 0.5, color = "black")) 
  
#############################################this does not include outliers - ones that ride over hour
last_12_months_filt <- last_12_months_all %>% filter(ride_hours == 0)

zaplot_filt <- last_12_months_filt %>% group_by(member_casual, day_of_week) %>% summarise(mean_time = mean(ride_time), max(ride_time), min(ride_time)) %>% 
  arrange(-mean_time) 


ggplot(zaplot_filt) + aes(y=mean_time, x = day_of_week) + geom_point(aes(color = member_casual, shape = member_casual)) + 
  labs(title = "Average ride time by day of the week (ignoring rides over 60min)", subtitle = "Casual Vs. Member") + xlab("Day od the week (7-Sunday, 1-Saturday)")+ 
  ylab("Average ride time")

last_12_months_filt %>% group_by(day_of_week, member_casual) %>% count(day_of_week) %>% arrange(-n) %>% 
  ggplot(aes(x=day_of_week, y=n)) + geom_point(aes(color= member_casual)) + labs(title = "Total rides by day of the week", subtitle = "Casual Vs. Member") +
  ylab("Total amount of rides") 

last_12_months_filt %>% ggplot(aes(x = ride_time)) + geom_histogram(aes(fill = member_casual )) + ggtitle("Ride Time - Member vs. Casual") +
  theme(plot.title = element_text(hjust = 0.5, color = "black"))




############boxplots
ggplot(last_12_months_all) + aes(y=ride_time) + geom_boxplot(aes(member_casual)) #bad

ggplot(last_12_months_filt) + aes(y=ride_time) + geom_boxplot(aes(color = member_casual)) + 
  labs(title = "Ride time distribution (ignoring rides over 60min)", subtitle = "Casual Vs. Member") +
  theme(plot.title = element_text(hjust = 0.5, color = "black"))#ok s filterom


last_12_months_filt %>%  group_by(member_casual) %>% count(day_of_week) %>% ggplot(aes(y=n)) + geom_boxplot(aes(color=member_casual)) + 
  labs(title = "Number of rides - Members Vs. Casuals", subtitle = "Filtered") + ylab("number of rides")  + theme(plot.title = element_text(hjust = 0.5, color = "black"))

last_12_months_all %>%  group_by(member_casual) %>% count(day_of_week) %>% ggplot(aes(y=n)) + geom_boxplot(aes(color=member_casual))  + 
  labs(title = "Number of rides - Members Vs. Casuals") + ylab("number of rides") + theme(plot.title = element_text(hjust = 0.5, color = "black"))


###################pie chart
last_12_months %>% group_by(member_casual) %>% count(member_casual) %>% ggplot(aes(x="", y =n, fill = member_casual)) + geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) + geom_text(aes(label = paste0(round((n/991204)*100), "%")), position = position_stack(vjust = 0.5)) +
  labs(x = NULL, y = NULL, fill = NULL, title = "User type") + theme(axis.line = element_blank(),
                                                                             axis.text = element_blank(),
                                                                             axis.ticks = element_blank(),
                                                                             plot.title = element_text(hjust = 0.5, color = "#666666"))


##########################3best months
last_12_months_all$started_at <- as.Date(last_12_months_all$started_at)
last_12_months_all$month <- format(as.POSIXct(last_12_months_all$started_at), format = "%d/%m/%Y")
last_12_months_all$started_at <- substr(last_12_months_all$started_at, 1, 10)

format(last_12_months_all$started_at)
str(last_12_months_all$started_at)

x <- last_12_months_all %>% group_by(start_station_name) %>% count(start_station_name) %>% arrange(-n)
head(x,13)
