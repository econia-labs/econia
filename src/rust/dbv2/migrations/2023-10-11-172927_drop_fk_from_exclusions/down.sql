ALTER TABLE competition_exclusion_list
ADD FOREIGN KEY ("user", "competition_id") 
REFERENCES competition_leaderboard_users("user", "competition_id");
