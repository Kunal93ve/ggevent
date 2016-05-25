# ggevent
Solution to the assignment
The data was given in .log format. It was converted to .json by simply editing the extension and the file was imported in RStudio workspace using jsonlite library.
sqldf library was used primarily for the unique user count problem so as to easilt write sql query to the data.
Further, the events were ranked in increasing order of time stamp and separate columns for 'ggstart' and 'ggstop' were created corresponding to each unique user and a given game id.
if rank of ggstop =  rank of ggstart+1, it counts for a successful session.
Since the data contains some ambiguity in the sequence of events (random occuerences of ggstart and ggstops), a successful session was considered only when one ggstart is followed by a ggstop and session length was counted for these appearing couple only. (Justification given in the pdf)
One alternate approach could have been to directly eliminate 'ggstart' if not followed by 'ggstop' and make a count when that occur.
