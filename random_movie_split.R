# this code randomly splits the movie list into two smaller lists

# define list of movies with 6 participants each
movielist <- c("12_years_a_slave", "the_prestige", "the_shawshank_redemption", "little_miss_sunshine",
               "the_usual_suspects", "back_to_the_future", "pulp_fiction", "split")

# define movies with a high number of participants
movie1 <- "500_days"
movie2 <- "citizenfour"

seed(1811) # set a seed

# define movielist1
movielist1 <- sample(movielist, 4)
movielist1 <- c(movie1, movielist1)

# define movielist2
movielist2 <- setdiff(movielist, movielist1)
movielist2 <- c(movie2, movielist2)
