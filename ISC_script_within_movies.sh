#!/bin/bash

source ~/.bashrc

##########################################
# INTERSUBJECT CORRELATION WITHIN MOVIES #
##########################################

path="/data/movie/fmri/participants/adults"

movie_list=(12_years_a_slave 500_days the_prestige the_shawshank_redemption little_miss_sunshine the_usual_suspects back_to_the_future citizenfour pulp_fiction split)
#movie_list=(split)
num_movies=${#movie_list[@]}

for (( m=0; m<${num_movies}; m++));
	do
        # define variable movie
        movie=${movie_list[$m]}
        echo $movie
	echo ""

	# change directory to movie folder
	cd "$path"/"$movie"/

	# define subjects based on folder names in the $movie directory
	subjects=""
	subjects=($(ls -d [0-9][0-9][0-9][0-9][0-9][0-9][A-Z][A-Z])) #subject ID 6 numbers + 2 letters

	# define which subjects should be excluded
	subjects_excl=(180317RC 180329NR 190805EM 200217TL)
	# exclude subjects: compare the elements of subjects_excl and subjects
	# if they match, delete (i.e. unset) the element in subject
	for e in ${!subjects_excl[@]}; do
        	excl=${subjects_excl[$e]}
        	for i in ${!subjects[@]}; do
        		subj=${subjects[$i]}
                	if [[ "$excl" == "$subj" ]]; then
                        	unset subjects[i]
                        	subjects=( "${subjects[@]}" )
                	fi
        	done
	done

	num_subjects=${#subjects[@]}
	echo number of subjects $num_subjects

        # create ISC folder
        ISC_dir="$path"/"$movie"/"ISC_analysis"/
        mkdir $ISC_dir
        cd $ISC_dir

	# create DataTable file
        #printf "Subj1\tSubj2\tInputFile\t\\" > ~/"$movie"_DataTable.txt
        printf "Subj1\tSubj2\tInputFile" > ./"$movie"_DataTable.txt

	# loop over subjects
	for (( s=0; s<${num_subjects}; s++));
		do
		# define variable subj_id
		subj_id=${subjects[$s]}
		echo $subj_id

		# change directory to where the bold data of subj_id is saved
       		s1_dir="$path"/"$movie"/"$subj_id"/

		# define file for subj_id
		s1_file=$s1_dir"media_all_tshift_despike_reg_al_mni_mask_blur6_norm_polort_motion_wm_ventricle_timing_ica.nii.gz"

		# check whether s1_file exists
		if [ -f "$s1_file" ]; then

			# loop over subjects+1
			for (( t=s+1; t<${num_subjects}; t++));
	        		do

	        		# define variable subj_corr, change directory to where the bold data of subj_corr is saved and define file for subj_corr
	        		subj_corr=${subjects[$t]}
	        		s2_dir="$path"/"$movie"/"$subj_corr"/

	                	# define file for subj_id
	                	s2_file=$s2_dir"media_all_tshift_despike_reg_al_mni_mask_blur6_norm_polort_motion_wm_ventricle_timing_ica.nii.gz"

				# check whether s2_file exists
				if [ -f "$s2_file" ]; then

					# define ISC_prefix
					ISC_prefix="ISC_${movie}_${subj_id}_${subj_corr}.nii.gz"

                                        # add information to DataTable file
                                        #printf "\n$subj_id\t$subj_corr\t$ISC_prefix\t\\" >> ~/"$movie"_DataTable.txt
                                        printf "\t\\\n$subj_id\t$subj_corr\t$ISC_prefix" >> ./"$movie"_DataTable.txt

					# compute ISC
					if [ ! -f "$ISC_prefix" ]; then

						echo ""
	           				echo s1_file $s1_file
	           				echo s2_file $s2_file
	         				echo ISC_prefix $ISC_prefix
						echo ""
						# calculate ISC using pearson, do not detrend the data, save it in .nii, do Fisher-z transformation
						3dTcorrelate -pearson -polort -1 -Fisher -automask -prefix $ISC_prefix $s1_file $s2_file
					fi

				else
					echo "s2_file $s2_file does not exist"
				fi
			done

		else
			echo "s1_file $s1_file does not exist"
		fi
	done

	# now for each movie, calcute the LME-CRE
	# within $ISC_dir, create file run_3dISC
	printf "3dISC -prefix ISC_$movie -jobs 4 -model '1+(1|Subj1)+(1|Subj2)' -dataTable @"$movie"_DataTable.txt" > ./run_3dISC_"$movie"
	# calculate ISC with LME-CRE
	source ./run_3dISC_"$movie" > ./output_3dISC_"$movie".txt

done

cd /data/movie/fmri/movie_scripts

