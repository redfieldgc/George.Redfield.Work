require "dbi"
require "ftools"
require 'logger'
require 'fileutils'


 begin
    dirLog = "I:/StoredFilesCopy/log"
    drLog = dirLog + '/' + 'log_delivery_table_create.log'
    $LOG = Logger.new(drLog, 'monthly')
    $LOG.level = Logger::DEBUG     #  DEBUG, INFO, WARN, ERROR, FATAL
   @db = DBI.connect("dbi:OCI8:f409", "index_admin", "bulawayo")
    $LOG.info(" ")
    $LOG.info("start #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}") 
    puts
    puts "Start  #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}" 
    
    valHash = { "collectionId" => "",                              
     "rsCollectionId" => ""} 
     
  aCollectionId = Array.new
  aRsCollectionId = Array.new
  
          query = "select ctl_collection_id, rs_collection_id from ctl_collection where fsi_table_name is null and rs_collection_id is not null"  
          stmt = @db.prepare(query)
          stmt.execute
           while (row = stmt.fetch)           
                  collectionId =  row[0].to_int.to_s
                  rossetaCollectionId =  row[1].to_s   
                            
          valHash["collectionId"] << collectionId          
          valHash["rsCollectionId"] << rossetaCollectionId
          
          aCollectionId << collectionId 
          aRsCollectionId << rossetaCollectionId

        #  puts valHash["collectionId"] 
       #   puts valHash["rsCollectionId"]
      #   puts "collectionId #{collectionId} rossetaCollectionId  #{rossetaCollectionId}"
          
        end       
         stmt.finish    
     
          aCollectionId.each_with_index do |collId, i|
          #  puts " #{i} collId #{collId} aRsCollectionId #{aRsCollectionId[i]}"
            tableName = "FSI_#{aRsCollectionId[i]}"
            
             query1 = "update ctl_collection set fsi_table_name = '#{tableName}' where ctl_collection_id = #{collId}"
             stmt1 = @db.prepare(query1)                    
             stmt1.execute
             stmt1.finish 
             
        
                                 
	                     query2 = "CREATE TABLE #{tableName}
	                    (                     
	                      RECORD_ID	VARCHAR2 (1024 Char),
	                      PROJECT_ID	VARCHAR2 (64 Char),
	                      IMAGE_ID	VARCHAR2 (1024 Char),
	                      IMAGE_TYPE	VARCHAR2 (1024 Char),
	                      OPERATOR	VARCHAR2 (128 Char),
	                      UNIQUE_IDENTIFIER	VARCHAR2 (64 Char),
	                      EVENT_TYPE	VARCHAR2 (1024 Char),
	                      DGS	VARCHAR2 (64 Char),
	                      CTL_FILE_ID	VARCHAR2 (1024 Char),
	                      IMAGE_NBR	VARCHAR2 (64 Char),
	                      GS_NUMBER	VARCHAR2 (64 Char)
	                     )
	                     "  
                       
                      # puts query2
                       
	                     stmt2 = @db.prepare(query2)
	                     stmt2.execute
	                     stmt2.finish                
   	 
	                    query3 = "GRANT DELETE, INSERT, SELECT, UPDATE ON #{tableName} TO FSICP"     
                      
                     # puts query3       
                     
	                   stmt3 = @db.prepare(query3)
                     stmt3.execute
                     stmt3.finish    
	 
	                    puts "table created #{tableName}"                
	              
  
             
          end                    
   

  
  $LOG.info("End  #{DateTime.now.strftime('%Y-%m-%d %H%:M:%S')}")  
  $LOG.info(" ")
  puts "End  #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')}"  
 
 

 rescue => err
        puts "Exception: #{err}"
         $LOG.info("Exception: #{err}")
 ensure
   @db.commit  
   #@db.rollback 
   @db.disconnect if @db  
 end  
 