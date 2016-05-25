################# Required package download
install.packages("jsonlite")
install.packages("sqldf")
library(sqldf)
library(jsonlite) 

#################	Save ggevent file with json extension (open ggeven.txt file and save as ggevent.json)      
json_file <- "D:/Ashish/Kunal/ggevent.json"                                       # file path
dat <- fromJSON(sprintf("[%s]", paste(readLines(json_file), collapse=",")))       # Reading data
final_dat <- cbind(dat$headers, dat$post, dat$params, dat$bottle)                 # Creating final data to analyze

################## 	1. Game wise distinct user count
game_wise_UserCount <- sqldf("select game_id, count(distinct(ai5)) count_user from final_dat group by game_id")
##############################################################
######### 	2. Game wise unique user count 
#########	3. session count and average session length for a user and for a game

unique_games <- unique(final_dat$game_id)	# Unique Games
subset_dat <- final_dat[, c(1, 5, 6, 7, 8)]	# Subsetting data with column ai5, event, ts, timestamp, game_id
out1 <- NULL
for(g in 1:length(unique_games)){			# loop over lenght of Games
	#print("game_id")
	#print(unique_games[g])
	unique_user <- unique(subset_dat$ai5[subset_dat$game_id == unique_games[g]])	# Unique user for gth Game(loop position as 'g')
	for(u in 1:length(unique_user)){												# loop over length of unique user
		#print("user")
		#print(unique_user[u])
		dat <- subset_dat[subset_dat$ai5 == unique_user[u] & subset_dat$game_id == unique_games[g], ]		# data subsetting for gth game and for uth user
		if(nrow(dat) > 0){					# If data is available for subsetting dataset then will proceed for session length and session count calculation
			dat <- dat[order(dat$timestamp),]				# Arrange in increasing order of timestamp
			dat <- mutate(dat, rank = rank(timestamp))		# Adding Rank column to the dataset with Rank 1 denotes Lowest timestamp
			session_start <- dat[dat$event == 'ggstart', c(4, 5, 6)]	# Subsetting data for condition on column event = 'ggstart' and keeping columns 'timestamp', 'game_id' and 'rank' with it
			session_stop <- dat[dat$event == 'ggstop', c(4, 5, 6)]		# Subsetting data for condition on column event = 'ggstop' and keeping columns 'timestamp', 'game_id' and 'rank' with it
			if(nrow(session_start) > 0 & nrow(session_stop) > 0){		# for a Game and for a User if count of 'ggstart' event and count of 'ggstop' event is positive than will proceed for session count and length calculation
				session_count <- 0		# Initializing session_count = 0
				session_length <- 0		# Initializing session_length = 0
				out <- NULL
				for(i in 1:nrow(session_start)){		# Loop over subsetted 'ggstart' event data
					for(j in 1:nrow(session_stop)){		# Loop over subsetted 'ggstop' event data
						if(session_stop$rank[j] == (session_start$rank[i]+1)){		# if rank of 'ggstop' event = 1+ rank of 'ggstart' event than will consider as a session
							session_count = session_count+1 		# Session Count
							session_length = session_length + (as.numeric(as.POSIXlt(session_stop$timestamp[j]) - as.POSIXlt(session_start$timestamp[i])))		  # session length = timestamp of 'ggstop' event - timestamp of 'ggstart' event
									# session length is in seceond										
						}
					}
				}	
				average_session_length = session_length/session_count		# Average session Length calculation
				out = cbind(unique_games[g], unique_user[u], session_count, average_session_length)		# column binding with required columns
				out1 <- rbind(out1, out)
			}
			#print(out1)
		}
	}
}
out1 <- as.data.frame(out1)
names(out1) <- c("game_id", "user_id", "session_count", "average_session_len")
write.csv(out1, "session_count_avgLen.csv")
write.csv(game_wise_UserCount, "game_wise_UserCount.csv")
##################################################################################################################################