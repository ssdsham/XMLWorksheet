
require 'nokogiri'
require 'CSV'


# Get list of input XML files


fileList = Dir.glob("../input/*.xml") 
	

	
	# For each XML file
for z in 0..fileList.length-1
    	#Global Variables
  	stepCount = 0
	termCount = 0
	
	stepStartIndex = 0
	stepEndIndex = 0
	termStartIndex = 0
	termEndIndex = 0
	
	# This variable is to identify the XML Tag that contains the payload
	payloadTagName = "return"	
    # Determine Path of current XML
    xml1 =  "#{Dir.pwd}" + "/" + "#{fileList[z]}"

    # Open the current XML file
	
    f1=File.open("#{xml1}", "r") 
	
	# Regex filname - we can save the outputFile with the same name
	outpfile_name = xml1[/([^:\\\/]*?)(?:\.([^ :\\\/.]*))?$/][$1]
	outputFile=File.open("../output/#{outpfile_name}.csv","w")
	
	# Column names for the CSV File
	outputFile.puts "Algorithm_Name,Category_Name,Type,Item,Step_Number,Step_Name,Term_Type,Value_Name,Value"

    # Parse the current XML file
	doc = Nokogiri::XML(f1)
	
	# Grabs all leaves nodes in the XML
	leaves = doc.xpath('//*[not(*)]')     		                       
	a = Array.new
	payload = ""
	leaves.each do |node|
	
		# Grab every node except the payload. 
		if node.name!= payloadTagName		
		# Do Nothing for Non-Payload Tags 
		
		else
		# Grab the payload tag and process as a new xml document
		payload = Nokogiri::XML("#{node.text}").root.to_xml         
		end
	
	end
    doc1 = Nokogiri::XML(payload) { |s| s.noblanks }

    # Initialize variables
    name = Array.new
    value = Array.new
    count = 0
   

    # Xpath for the algorithm, step and term values in XML
	attrAlgorithm=doc1.xpath("//worksheets/worksheet/algorithm")
	attrStep=doc1.xpath("//worksheets/worksheet/algorithm/step")
	attrTerm=doc1.xpath("//worksheets/worksheet/algorithm/step/term")

	print "Parsing File: #{outpfile_name}... \n"


	globStepCount = attrStep.count
	globTermCount = attrTerm.count
	
	# For each algorithm, we scan the step and for each step, we scan the terms!
	# AlgorithCount, TermCount, StepCount are global throughout the XML
	# StepIndex and TermIndex are also global throughout the XML
	
	csvString = ""
		for i in 0..attrAlgorithm.length-1
			row = Array.new
			csvString = csvString+"\n"
			for l in 0..attrAlgorithm[i].keys.length-1
				#p attrAlgorithm[i].keys[l] + " : " + attrAlgorithm[i].values[l]
				#row.push attrAlgorithm[i].values[l]
				csvString = csvString + attrAlgorithm[i].values[l] + ","
				#csvRows.push attrAlgorithm[i].values[l]
			end
			
			
			
			stepCount = attrAlgorithm[i].children.count
			#p "stepCount is #{stepCount}"
			#p "globStepCount is #{globStepCount}"
			stepEndIndex = stepStartIndex + (stepCount-1)
			globStepCount = globStepCount - stepCount
			
				if globStepCount>=0
					 ##counter = 0
					 for j in stepStartIndex..stepEndIndex
						 #stepRow = Array.new
						 

						  
						 
						 for l in 0..attrStep[j].keys.length-1
											 
							 #p attrStep[j].keys[l] + " : " +  attrStep[j].values[l]
							 
							 	csvString = csvString + attrStep[j].values[l] + ","
												 
						 end

					 
							termCount = attrStep[j].children.count
							termEndIndex = termStartIndex + (termCount-1)
							globTermCount = globTermCount - termCount


							if globTermCount>=0
								for k in termStartIndex..termEndIndex
									for l in 0..attrTerm[k].keys.length-1
									#p attrTerm[k].keys[l] + " : " +  attrTerm[k].values[l] + " : "  + attrTerm[k] 
										csvString = csvString + attrTerm[k].values[l] + ","
										if attrTerm[k].keys.length==1
											csvString = csvString + ","
										end
									end
									
									csvString=csvString + attrTerm[k]
									#puts attrTerm[k]
								# Reset Line for New Term
								csvString= csvString+"\n,,,,,,"
								termStartIndex = termStartIndex + 1	
								end


							else 
							break
							end
					 
					 stepStartIndex = stepStartIndex + 1	
					 # Reset Line for New Step
					 csvString= csvString+"\n,,,,"
					 end
					
				
				else 
				break
				end
		 
		
		#csvRows.push row
		end

#File.open("../output/output.csv", "a") {|f| f.write(csvRows.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}

# Save it all to the output CSV File
outputFile.puts csvString
outputFile.close
print "Parsing Complete! \n"
end