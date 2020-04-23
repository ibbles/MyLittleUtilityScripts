function fish_prompt
  # Save the exit status of the previous user comment.
  set -l last_status $status

  echo ""

  # Print the working directory.
  # Using echo to avoid trailing newline.
  set_color red
  echo -n (pwd) | sed "s,^/home/$USER,~,"

  # Add an error marker if the previous command failed.
  if test $last_status -gt 0
     set_color red --bold
	 echo -n "[$last_status]"
  end

  # A marker for the number of background jobs.
  set -l numJobs (jobs | wc -l)
  if test $numJobs -gt 0
     set_color $fish_color_normal
     echo -n "[$numJobs]"
  end

  # Move to a new line.
  echo -en "\n"

  # The current git branch.
  set branch (branchname)
  if test "$branch" != ""
     set_color normal
     echo -n "⎇ "
     set_color green
     echo -n "$branch"
  end

  # A green ➤ to mark the end of the prompt.
  set_color green --bold
  echo -n '➤ '
  set_color normal
end
