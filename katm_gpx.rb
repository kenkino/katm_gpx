##################################################
#
#   KML file convert to add on time GPX file ( Katm_gpx.rb )
#
#   2012/09/12 KINOSHITA Kenichi
#
##################################################

def timeset( setline )
	ctime = setline.scan(/[\d]+/)
	settime = Time.local( ctime[0], ctime[1], ctime[2], ctime[3], ctime[4], ctime[5])
	return settime
end
def timecal( stime, etime)
	iscaltm = ( etime - stime )
	puts "logging time : #{iscaltm} seconds"
	return iscaltm
end

#interval calculations
def invalcal( ipnt, itime )
	puts "logging points : #{ipnt}"
	ival = itime / ipnt
	return ival
end 

#Main Task
if ARGV.size >= 2

	$name = "name"
	$descr = "<description>"
	$sdescr = "</description>"
	$coord = "<coordinates>"
	$scoord = "</coordinates>"
	$point = "/Point"
	$LS = "<LineString>"
	$LSLST = "</LineString>"
	$LAT = "lat="
	$LON = "lon="
	$ELEH = "<ele>"
	$ELEHU = "</ele>"
	$ELET = ".000000"
	$DC = "\""
	$TIME = "<time>"
	$TIMEU = "</time>"
	$comma = ","
	$ELOG = "EXILIM LOG"
	$cdata = "CDATA"
	pflag = 0
	sflag = 0
	pline = 0
	elog = 0
	fTm = ""
	stm = ""
	etm = ""
	spos = ""
	epos = ""
	tstmp = ""

	# KML File Open
	infile = ARGV[0]
	begin
		s = File::stat( infile )
	rescue
		puts "Convert master file not found!!"
		exit!
	end

	inline = open( infile, "r")

	# Time interval set

	# GPX File Open
	outfile = ARGV[1]
	begin
		s = File::stat( outfile )
	rescue
	else
		puts "Convert file is exist!"
		exit!
	end
	outline = open( outfile, "w")
 
	# Temp file Open
	require 'tempfile'
	temp = Tempfile::new("katm", "/tmp")

	# Write GPX File Header
	outline.puts("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
	outline.puts("<gpx version=\"1.0\">")

	while( line = inline.gets )
		nm = line if /#{$name}/
		if /#{$ELOG}/ =~ line
			elog = 1
		end
		if elog == 0
			if /#{$descr}/ =~ line
				if sflag == 0
					starttm = timeset( line )
				else
					if sflag == 1
						endtm = timeset( line )
					end
				end
				sflag = sflag + 1
				cm = line.gsub(/description+/,"cmt")
				dm = cm.gsub(/cmt+/,"desc")
			end

			cod = line if /#{$coord}/

			if /#{$point}/ =~ line
				pos = cod.scan(/([\d\.]+)/)
				ym = dm.scan(/([\d\.\:]+)/)
				tm = dm.scan(/[\d]+/)
				if sflag == 1
					stm = starttm
				end
				# Write Start Point & Goal Point
				outline.puts("<wpt #{$LAT}#{$DC}#{pos[1]}#{$DC} #{$LON}#{$DC}#{pos[0]}#{$DC} >#{$ELEH}#{pos[2]}#{$ELET}#{$ELEHU}")
				outline.puts("#{nm}")
				outline.puts("#{cm}")
				outline.puts("#{dm}")
				outline.puts("</wpt>")
				# Write Start Point & Goal Point
			end
			if /#{$scoord}/ =~ line
				pflag = 0
			end
			# Count Track Point Start
			if pflag == 1
				if /#{$comma}/ =~ line
					pline = pline + 1
				end
			end
			if /#{$LS}/ =~ line
				pflag = 1
			end
			# Count Track Point End
		elsif
			if /#{$cdata}/ =~ line
				cline = line.scan(/[\d]+/)
				fTm = Time.local( cline[0], cline[1], cline[2], cline[3], cline[4], cline[5])
				tstmp = fTm.strftime("%Y-%m-%dT%H:%M:%SZ")
				if pline == 0
					stm = fTm
				elsif
					etm = fTm
				end
			elsif /#{$coord}/ =~ line
				if /#{$comma}/ =~ line
					pos = line.scan(/([\d\.]+)/)
					temp.puts("<trkpt #{$LAT}#{$DC}#{pos[1]}#{$DC} #{$LON}#{$DC}#{pos[0]}#{$DC}>")
					temp.puts("#{$ELEH}#{pos[2]}#{$ELEHU}#{$TIME}#{tstmp}#{$TIMEU}")
					temp.puts("</trkpt>")
					if pline == 0
						spos = pos
					elsif
						epos = pos
					end
					pline = pline + 1
				end
			end
		end
	end  # Read KML File Loop END
	inline.close

	temp.close
	# EXILIM LOG Write Start Point and End point 
	if elog == 1
		temp.open
		tstmp = stm.strftime("%Y/%m/%d-%H:%M:%S")
		outline.puts("<wpt #{$LAT}#{$DC}#{spos[1]}#{$DC} #{$LON}#{$DC}#{spos[0]}#{$DC} >#{$ELEH}#{spos[2]}#{$ELEHU}")
		outline.puts("<name> EXILIM LOG Start </name>")
		outline.puts("<cmt> Start Time : #{tstmp} </cmt>")
		outline.puts("<desc> Start Time : #{tstmp} </desc>")
		outline.puts("</wpt>")

		tstmp = etm.strftime("%Y/%m/%d-%H:%M:%S")
		outline.puts("<wpt #{$LAT}#{$DC}#{epos[1]}#{$DC} #{$LON}#{$DC}#{epos[0]}#{$DC} >#{$ELEH}#{epos[2]}#{$ELEHU}")
		outline.puts("<name> EXILIM LOG END </name>")
		outline.puts("<cmt> End Time : #{tstmp} </cmt>")
		outline.puts("<desc> End Time : #{tstmp} </desc>")
		outline.puts("</wpt>")
		outline.puts("<trk>")
		outline.puts("<trkseg>")
	end

	if elog == 0
		puts "Auto Make Time Stamps"
		iruntm = timecal( starttm, endtm )
		interval = invalcal( pline, iruntm )
		puts "interval : #{interval}"
	elsif
		puts "Get EXILIM KML Time Data"
	end

	if elog == 0
		# KML File reOpen
		infile = ARGV[0]
		inline = open( infile, "r")

		pline = 0
		while(line = inline.gets)  # Write Track Point Loop

			if /#{$scoord}/ =~ line
				pflag = 0
			end
			# Write Track Point Start
			if pflag == 1
				if /#{$comma}/ =~ line
					if pline > 0
						stm = stm + interval
						tstmp = stm.strftime("%Y-%m-%dT%H:%M:%SZ")
					else
						outline.puts("<trk>")
						outline.puts("<trkseg>")
					end   
					pos = line.scan(/([\d\.]+)/)
					outline.puts("<trkpt #{$LAT}#{$DC}#{pos[1]}#{$DC} #{$LON}#{$DC}#{pos[0]}#{$DC}>")
					outline.puts("#{$ELEH}#{pos[2]}#{$ELET}#{$ELEHU}#{$TIME}#{tstmp}#{$TIMEU}")
					outline.puts("</trkpt>")
					pline = pline + 1
				end
			end
			# Write Track Point End

			if /#{$LS}/ =~ line
				pflag = 1
			end

		end  # Read KML File Loop END
	elsif
		temp.each { |line| outline.puts(line) }
		temp.close(true)
	end
end
outline.puts("</trkseg>")
outline.puts("</trk>")
outline.puts("</gpx>")
if elog == 0
	inline.close
end
outline.close
