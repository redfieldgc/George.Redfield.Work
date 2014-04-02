require "dbi"
require "ftools"
require 'fileutils'   
require 'logger'
require 'libarchive'
 

class File
  def File.chked_filenameMove(base, dirr, ckdir, first_suffix='_00')
    suffix = nil
    filename = base
    dr = dirr + filename    
    chkdr = ckdir + filename     
    while File.exists?(chkdr)
      suffix = (suffix ? suffix.succ : first_suffix)  
      len = base.length
      cutEnd = len - 8
      filename = base[0..cutEnd] + suffix + '.xml'
      chkdr = ckdir + filename
    end  
     File::move(dr, chkdr, verbose = false)
    return filename
      rescue => err
        puts "Exception1: #{err}"
        $LOG.error("Exception1: #{err}") 
        raise
  end
  
  
   def File.chked_filenameCopy(base, dirr, ckdir, first_suffix='_00')
    suffix = nil
    filename = base
    dr = dirr + filename    
    chkdr = ckdir + filename     
    while File.exists?(chkdr)
      suffix = (suffix ? suffix.succ : first_suffix)  
      len = base.length
      cutEnd = len - 8
      filename = base[0..cutEnd] + suffix + '.xml'
      chkdr = ckdir + filename
    end  
     File::copy(dr, chkdr, verbose = false)
    return filename
    
    rescue => err
        puts "Exception2: #{err}"
        $LOG.error("Exception2: #{err}") 
        raise
      end
      
      
  def File.chked_filename(base, dirr, ckdir, first_suffix='_00')
    suffix = nil
    filename = base
    dr = dirr + filename    
    chkdr = ckdir + filename     
    while File.exists?(chkdr)
      suffix = (suffix ? suffix.succ : first_suffix)  
      len = base.length
      cutEnd = len - 8
      filename = base[0..cutEnd] + suffix + '.xml'
      chkdr = ckdir + filename
    end  
    return filename
     rescue => err
        puts "Exception3: #{err}"
        $LOG.error("Exception3: #{err}") 
        raise
  end  
  
end # class File 


class String
  
def rtrim(char)
dump.rtrim!(char)
end

def rtrim!(char)
gsub!(/#{Regexp.escape(char)}+$/, '')
end

def ltrim(char)
dump.ltrim!(char)
end

def ltrim!(char)
gsub!(/^#{Regexp.escape(char)}+/, '')
end     
           
end # class String
 
def MoveToStart(vHsh)
  dir0 = vHsh["dirPush"] 
   Dir.foreach(dir0)  do |x| 
     if x != "." && x != ".."
       d1 = vHsh["dirPush"] + "/" + x
       d2 = vHsh["dirStart"] + "/" + x
              
       File::copy(d1, d2, verbose = false)  
       File.delete(d1) 
    end
  end
    rescue => err
        puts "Exception40: #{err}"
        $LOG.error("Exception40: #{err}") 
        raise
      end # MoveToStart(vHsh)
      
      

  def MoveEasyLoadFiles(vHsh)  # move last load files to unprocessed file pool 
   dir0 = vHsh["dirLegacyStart"]
   Dir.foreach(dir0)  do |x| 
     if x != "." && x != ".."
       d1 = vHsh["dirLegacyStart"] + "/" + x
       d2 = vHsh["dirLegacyPrevious"] + "/" + x
              
       File::copy(d1, d2, verbose = false)  
       File.delete(d1) 
    end
  end
    rescue => err
        puts "Exception4: #{err}"
        $LOG.error("Exception4: #{err}") 
        raise
      end # MoveEasyLoadFiles(vHsh)
      
      
 
  
  def DeleteFsiXmlFiles(vHsh)  # Delete the small xml files from load start directory. They usually come in larger data xml and small definition xml.
   dr0 = vHsh["dirStart"]   
   dr1 = vHsh["dirXml"]           # Temporary directory to put already unzipped xml files into.
   dr2 = vHsh["dirProblemFiles"]
   
   Dir.foreach(dr0)  do |x| 
   if x != "." && x != ".." 
     
      if x =~ /.tar.gz/ 
        d0 = dr0 + "/" + x
        d2 = dr2 + "/" + x 

        if  File.size?(d0) > 10000000                      
            File::copy(d0, d2, verbose = false)  
            File.delete(d0)  
            
        end            
      end       
     
    
     if x =~ /.xml/ 
      d0 = dr0 + "/" + x
      d1 = dr1 + "/" + x
      d2 = dr2 + "/" + x
      
      if File.size?(d0) < 240 then 
          File.delete(d0)
   #   elsif  File.size?(d0) > 200000000      
      
    #   File::copy(d0, d2, verbose = false)  
    #   File.delete(d0)       
          
      else         
       File::copy(d0, d1, verbose = false) 
       vHsh["fStartArray"] << d1
       File.delete(d0)
     end 
    
   end
 end  
end 
  
    rescue => err
        puts "Exception5: #{err}"
        $LOG.error("Exception5: #{err}") 
        raise
end # DeleteFsiXmlFiles(vHsh) 
 
  

 def UnZipFiles(vHsh)   # Unzip tar gz files from start directory to the temporary unzipped xml directory.
dir1 = vHsh["dirStart"]
dir2 = vHsh["dirXml"]
Dir.foreach(dir1)  do |x| 
  if x != "." && x != ".."
    $LOG.debug("6: #{dir1}  #{dir2}  #{x}")
    y1 = "#{dir1}/#{x}"
    fin = "#{y1}"
    y2 = x[0 .. 8]
    y3 = "#{dir2}/#{y2}"
    fout = "#{y3}.xml"
    f1 = open(fout,'w')
    $LOG.debug("61: #{y1}  #{y2}  #{y3}  #{fout}")
    Archive.read_open_filename(fin) do |ar|
      while entry = ar.next_header
        name = entry.pathname
        data = ar.read_data
        f1.puts "#{data}"
      end
    end
      f1.close
 end
 end
 #exit
  rescue => err
        puts "Exception6: #{err}" 
        $LOG.error("Exception6: #{err}") 
        raise 
end # UnZipFiles(vHsh)
  


 def DeletefArray(vHsh)   # clear array
    vHsh["fDeleteArray"].each_with_index do |y,i|
    File.delete(y)
    end
    rescue => err
        puts "Exception15: #{err}"
        $LOG.error("Exception15: #{err}") 
        raise
   end # DeletefArray(vHsh)

 

 def RemoveAmp(vHsh)   # modify files that contain ' & ' replace with ' &amp; '
        x = vHsh["fFileName"]
        dir01 = vHsh["dirXml"]
        d1 = dir01 + "/" + x
        t1 = "#{dir01}/temp" 
        count3 = 0   
        
        temFile = File.open(t1, "w+")
        temFile.flock(File::LOCK_EX)      
               
         x1File = File.open(d1,"r")   
         x1File.flock(File::LOCK_EX)
       
         while (line = x1File.gets)
            count3 = count3 + 1
            temFile.puts line.gsub(' & ',' &amp; ')   # replace every ' & ' with ' &amp; '
         end
     
         x1File.flock(File::LOCK_UN) 
         if !x1File.closed? then x1File.close end
         
         temFile.flock(File::LOCK_UN)     
         if !temFile.closed? then temFile.close end      
         File::copy(t1, d1,verbose = true)       
         File.delete(t1)   
         
       rescue => err
       puts "Exception10: #{err}"
       $LOG.error("Exception10: #{err}") 
       raise
  end  # RemoveAmp(vHsh)
    
  
  
 def GetFileDGS(vHsh)  # Get the file DGS number in the first 5 lines of file. Returns DGS value or unknown in vHsh["fDgs"]
        x = vHsh["fFileName"]
        dir01 = vHsh["dirXml"]
        d1 = dir01 + "/" + x
        lineCount = 0
        dgs = 0
        nStart = ' '
        sDGS = ' '  
        myfile = File.open(d1,"r")
        while nStart == ' ' and lineCount < 6
           sInText = myfile.readline
           lineCount = lineCount + 1
           if sInText =~ /DGS/ 
              nStart = sInText.index('DGS') + 5
              nEnd = nStart + 8
              sDGS = sInText [nStart .. nEnd] 
                           
            end
          end 
          if sDGS == ' ' then
            $LOG.debug("No file DGS for: #{x}") 
            vHsh["fDgs"] = 'unknown' 
            else
             vHsh["fDgs"] = sDGS.ljust(9,"0")  # Pad zeros if needed
          end  
          ShowHash(vHsh)
        rescue => err
        puts "GetFileDGS(vHsh): #{err}"
        $LOG.error("GetFileDGS(vHsh): #{err}") 
        raise
        ensure
        myfile.close
    end # GetFileDGS(vHsh)
    
    
  
   def GetFileRecordCount(vHsh)
       if vHsh["fDgs"] != 'unknown'
         tDistinct = vHsh["fileRecordCount"]
         query = "select count(distinct(ctl_project_id)) 
              from ctl_file 
              where digital_gs_number = '#{vHsh["fDgs"]}' "  
          
          $LOG.debug("GetFileRecordCount #{query}")    
          stmt = @db.prepare(query)
          stmt.execute
          row = stmt.fetch 
          stmt.finish
          tDistinct  = row[0]
          $LOG.debug("fileRecordCount #{tDistinct}")           
          vHsh["fileRecordCount"] = tDistinct.to_int 
          ShowHash(vHsh)
          end
        rescue => err
        puts "GetFileRecordCount: #{err}"
        $LOG.error("GetFileRecordCount: #{err}") 
        raise
   end # GetFileRecordCount(vHsh)
  
  
      def GetFilePPQ(vHsh)  # Get the file PPQ number in the first 5 lines of file. Returns PPQ value or unknown in vHsh["fPpqId"]
                                       #d1 = @dir1 + "\\" + @x      
        x = vHsh["fFileName"]
        dir01 = vHsh["dirXml"]
        d1 = dir01 + "/" + x
        lineCount = 0        
        myfile = File.open(d1,"r")    

        firstQuote = 0
        secondQuote = 0
        underScore = 0
        posCount = 0
        stringLen = 0
        lineCount = 0
        nStart = ' '
        sTravellerID = ' '
        sDGS = ' ' 
        sPpq = ' '
        dpWuId              = ' '
        dpWuProjectId     = ' '
        dpCwuMapCwuId  = ' '
        dpCwU2Dgs         = ' '
        ShowHash(vHsh) 
        while nStart == ' ' and lineCount < 6 
          fInText = myfile.readline
         #fInText = "<container DGS=\"004174175\" version=\"2\" travellerID=\"12-0532_49040\" recordType=>"
         #fInText = "<container DGS=\"004174175\" version=\"2\" travellerID=\"12-0532_49040\" recordType=>"
          stringLen = fInText.length
          sInText = fInText
          #puts sInText
          lineCount = lineCount  + 1
             if sInText =~ /travellerID/ 
              nStart = sInText.index('travellerID') 
              subStr1 = sInText [nStart .. stringLen]
              while secondQuote == 0 
                   posCount = posCount + 1              
                   if firstQuote != 0
                        if subStr1[posCount,1] == "\""
                             secondQuote = posCount-1 
                        end 
                   end  
                   if subStr1[posCount,1] == "\"" and secondQuote == 0                            # travellerID="12-0001"
                         firstQuote = posCount + 1                                                              # travellerID="45828"
                   end                                                                                                  # travellerID="12-0001_45828"               
                   if subStr1[posCount,1] == "_"                                                             
                         underScore = posCount -1
                   end    
               end  
               
               if underScore != 0
                   sPpq = subStr1 [firstQuote .. underScore]
                    stravellerID = sPpq
               elsif nStart != 0 
                    stravellerID = subStr1 [firstQuote .. secondQuote]
               end 
                  
               if  stravellerID == 'null' then stravellerID = nil end
               if  stravellerID == 'unknown' then stravellerID = nil end  
           end                 
         end # while
         
         #puts " stravellerID +#{stravellerID}+"
    
         
         if stravellerID =~ /-/
            vHsh["fPpqId"]  = stravellerID        # file ppq found
        elsif stravellerID == nil
            vHsh["fPpqId"]  = 'unknown' 
        else
            wuNumber = stravellerID  # work unit only get to this part
           # puts " wuNumber #{wuNumber}"
             query = "SELECT DP_WU.ID,
                 DP_WU.PROJECT_ID,
                 DP_CWU_WU_MAP.CWU_ID,
                 DP_CWU2.DGS
               FROM DP_WU@rosetta,DP_CWU_WU_MAP@rosetta,DP_CWU2@rosetta
               WHERE DP_WU.ID = DP_CWU_WU_MAP.WU_ID  
               AND
               DP_CWU2.CWU_ID = DP_CWU_WU_MAP.CWU_ID
               AND 
               DP_WU.ID = #{wuNumber}   
               AND 
               DP_CWU2.DGS = '#{ vHsh["fDgs"] }'"
    
          #puts("GetFilePPQ query1 #{query}")
          stmt = @db.prepare(query)
          stmt.execute
          row = stmt.fetch 

          if row == nil    
          dpWuId              = ' '
          dpWuProjectId     = 'unknown'
          dpCwuMapCwuId  = ' '
          dpCwU2Dgs         = ' '
          else
          dpWuId                  = row[0]
          dpWuProjectId        = row[1] 
          dpCwuMapCwuId     = row[2]
          dpCwU2Dgs            = row[3]          
         end 
         vHsh["fPpqId"]  =  dpWuProjectId 
                  
  
#puts("row #{row}") 
#puts("dpWuProjectId #{row[1]}") 
#puts("dpWuId #{row[0]}") 
            
        end
        rescue => err
        puts "Exception12: #{err}"
        $LOG.error("Exception12: #{err}") 
        raise
        ensure
        myfile.close 
       end # GetFilePPQ(vHsh)
 
 
      
      
                                         # Get more info from tables
 def GetTable(vHsh)             # Get values from Oracle Tables, return value or unknown in vHsh["tPpqId"] , value of ctl_file_id  in vHsh["tFileId"] or leave alone, value of ctl_status in vHsh["tStatus"] or leave alone.
        x = vHsh["fFileName"]                
        dir01 = vHsh["dirXml"]
        d1 = dir01 + "/" + x
        lineCount = 0
        dgs = 0
        sDGS = ' '  
        tDgsCount = 0
        tPPQ = ' '
        tCtlFileId = 0
        tDistinct  = vHsh["fileRecordCount"] 
        vHsh["tDgs"]  = vHsh["fDgs"] # assume correct
        vHsh["tPpqId"]  = vHsh["fPpqId"]      
      
       if tDistinct == 1        # will find from query of table using file dgs
                        
          query = "SELECT f.ctl_file_id, T.PPQ_ID, f.ctl_status_id,P.CTL_PROJECT_ID
               FROM ctl_file f ,ctl_project p, ctl_traveler t
               WHERE f.digital_gs_number = '#{vHsh["tDgs"]}'
                AND  f.CTL_PROJECT_ID = p.ctl_project_id
                AND  P.CTL_TRAVELER_ID = T.CTL_TRAVELER_ID"  
           
           $LOG.debug("GetTable query1 #{query}")     
           stmt = @db.prepare(query)
           stmt.execute
           row = stmt.fetch 
           vHsh["tFileId"] = row[0].to_i
           vHsh["tPpqId"] = row[1]
           vHsh["tStatus"] = row[2]
           vHsh["tProjId"] = row[3].to_i
           stmt.finish
           vHsh["fPpqId"] = vHsh["tPpqId"]  # We found it
           
        elsif vHsh["fPpqId"] != 'unknown' and vHsh["fDgs"] != 'unknown' # info came in with file
          vHsh["tPpqId"] = vHsh["fPpqId"]  # assume correct
          
          query = "SELECT f.ctl_file_id, T.PPQ_ID, f.ctl_status_id,P.CTL_PROJECT_ID
               FROM ctl_file f ,ctl_project p, ctl_traveler t
               WHERE f.digital_gs_number = '#{vHsh["tDgs"]}'
                AND  f.CTL_PROJECT_ID = p.ctl_project_id
                AND  P.CTL_TRAVELER_ID = T.CTL_TRAVELER_ID
                AND T.PPQ_ID = '#{vHsh["tPpqId"]}'"  
           # puts query            
           $LOG.debug("GetTable query2 #{query}")
           stmt = @db.prepare(query)
           stmt.execute
           row = stmt.fetch 
           vHsh["tFileId"] = row[0].to_i
           vHsh["tStatus"] = row[2]
           vHsh["tProjId"] = row[3].to_i
           stmt.finish
           else
             puts 'indeterminate'
         end       
        ShowHash(vHsh)
        rescue => err
        puts "Exception11: #{err}"
        $LOG.error("Exception11: #{err}") 
        raise
 end # GetTable(vHsh)
 
 
 
  def CtlFilePropertyVersion(vHsh)  # Determin file  name and status. Update ctl_file_property
                                                    #  vHsh["tNewStatus"] = newStatus  
 $LOG.debug(" fPpqId value  #{vHsh["fPpqId"]}  ")
 $LOG.debug(" vHsh[tPpqId] vHsh[tFileId] vHsh[tStatus] values  #{vHsh["tPpqId"]}  #{vHsh["tFileId"]}  #{vHsh["tStatus"]}")
 ShowHash(vHsh)
  
  if vHsh["fPpqId"] =='unknown' and vHsh["tPpqId"] =='unknown'    # indeterminate
        vHsh["tStatus"] = 93
      end
          
     sVersionName = vHsh["fVersionFileName"]
     query = "select file_dgs, file_ppq_id,version_number 
           from ctl_file_property 
           where file_dgs = '#{vHsh["fDgs"]}' and file_ppq_id = '#{vHsh["fPpqId"]}' 
           order by  version_number desc"
      $LOG.debug("CtlFilePropertyVersion query1 #{query}")
      stmt = @db.prepare(query)    
      stmt.execute
      row = stmt.fetch
      
      if row != nil
        fdgs = row[0]
        fppq = row[1]
        fversion = row[2]
      end
        stmt.finish   

      if row != nil  
        newVersion = fversion + 1        
        newVersionString =  "%02d" % newVersion
       # dgs = vHsh["fDgs"].reverse.chomp('0').reverse
        dgs = vHsh["fDgs"].gsub(/\A0*/,'') # remove leading 0's
        newName = "#{dgs}_#{vHsh["fPpqId"]}_#{newVersionString}.xml" 
        query = "update ctl_file_property set version_number = #{newVersion}, file_name_versioned = '#{newName}'  
           where file_dgs = '#{vHsh["fDgs"]}' and file_ppq_id = '#{vHsh["fPpqId"]}'"
       $LOG.debug("CtlFilePropertyVersion query3 #{query}")
        stmt = @db.prepare(query)    
        stmt.execute
        stmt.finish
      else 
   
        newVersion = 0
        newVersionString =  "%02d" % newVersion
        dgs = vHsh["fDgs"].gsub(/\A0*/,'')
        newName = "#{dgs}_#{vHsh["fPpqId"]}_#{newVersionString}.xml"
       $LOG.debug(" new_name insert #{newName}")
       if vHsh["tFileId"] == ' '
        query = "insert into ctl_file_property (file_dgs, file_ppq_id, version_number, file_name_versioned )
        values('#{vHsh["fDgs"]}', '#{vHsh["fPpqId"]}',#{newVersion}, '#{newName}')"
        else          
        query = "insert into ctl_file_property (file_dgs, file_ppq_id, version_number, file_name_versioned, ctl_file_id )
        values('#{vHsh["fDgs"]}', '#{vHsh["fPpqId"]}',#{newVersion}, '#{newName}', #{vHsh["tFileId"]})"
       end   
       $LOG.debug("CtlFilePropertyVersion query2 #{query}")
        stmt = @db.prepare(query)    
        stmt.execute
        stmt.finish
          
        end  
        
       vHsh["fNewVersionFileName"] = newName       
       status = vHsh["tStatus"].to_s
       newStatus = 0
       if status == '67'  #created              
          newStatus = 92    #ready to load data into IMS          
       elsif  status == '92'
          newStatus = 92              
       elsif  status == '180'  #rework
          newStatus = 185  #ready to load rework data into IMS             
       elsif  status == '181'  #rework
          newStatus = 186  #ready to load rework data into IMS audit
       elsif  status == '94'  #hold
           newStatus = 94   
       elsif  status == '300'  
           newStatus = 81          # rework rereceive   
       elsif  status == '325'  
           newStatus = 81             
       elsif  status == '350'  
           newStatus = 81                       
       else
           newStatus = 93   #problem             
       end      
       vHsh["tNewStatus"] = newStatus 
       ShowHash(vHsh)  
           
     
    rescue DBI::DatabaseError => e
        puts "An error occurred 13"
        puts "Error code:    #{e.err}"
        puts "Error message: #{e.errstr}"
        $LOG.error("Exception13: #{e.err}") 
        raise
   
    end                        # CtlFilePropertyVersion(vHsh)
  
  
  
 def MoveToLegacy(vHsh) 
        y = vHsh["fFileName"]
        z = vHsh["fFileName"].chomp('.xml')
        x = "#{z}.tar.gz"
        dir01 = vHsh["dirStart"]
        d1 = dir01 + "/" + x
        dir02 = vHsh["dirLegacyStart"]
        d2 = dir02 + "/" + x
        dir03 = vHsh["dirXml"]
        d3 = dir03 + "/" + y
        dir04 = vHsh["dirProblemFiles"]
        d4 = dir04 + "/" + y
        t = FileTest::exists?("#{d1}")
       if t  then
         File::copy(d1, d2, verbose = false)   # If tar.gz in start directory move to Legacy. If in xml form move to problems (probably belongs to EASy).
         #File::move(d1, d2, verbose = false)          
         File.delete(d1) 
         vHsh["fDeleteArray"] << d3
         else
          File::copy(d3, d4, verbose = false)   
          #File::move(d3, d4, verbose = false)           
          vHsh["fDeleteArray"] << d3 
       end
    rescue => err
        puts "Exception7: #{err}"
        $LOG.error("Exception7: #{err}") 
        raise
  end  #  MoveToLegacy(vHsh)   
  
 

 def CopyToProduction(vHsh) 
     # puts '------------------------------------------------------------------'
     # puts vHsh["fFileName"]
       y = vHsh["fFileName"]
       newName = vHsh["fNewVersionFileName"]
       dir01 = vHsh["dirXml"]
       d1 = dir01 + "/" + y
       dir02 = vHsh["dirIMS"]
       d2 = dir02 + "/" + newName
       dir03 = vHsh["dirXml"]
       d3 = dir03 + "/" + y
       dir04 = vHsh["dirProblemFiles"]
       d4 = dir04 + "/" + newName
       t = FileTest::exists?("#{d1}")
       if t  then
          File::copy(d1, d2, verbose = false)   
         else
          File::copy(d3, d4, verbose = false) 
       end
      rescue => err
        puts "Exception8: #{err}"
        $LOG.error("Exception8: #{err}") 
        $LOG.error("newName_: #{newName}") 
        $LOG.error("d1_: #{d1}") 
        $LOG.error("d2_: #{d2}") 
        $LOG.error("d3_: #{d3}") 
        $LOG.error("d4_: #{d4}") 
        raise
      end  # CopyToProduction(vHsh) 
      
 
 
   def MoveToArchive(vHsh)    
        y = vHsh["fFileName"]
        newName = vHsh["fNewVersionFileName"]
        dir01 = vHsh["dirXml"]
        d1 = dir01 + "/" + y
        dir02 = vHsh["dirIMSArchive"]
        d2 = dir02 + "/" + newName
        dir04 = vHsh["dirProblemFiles"]
        d4 = dir04 + "/" + newName
        t = FileTest::exists?("#{d1}")
       if t  then
         File::copy(d1, d2, verbose = false)  
         else
          File::copy(d1, d4, verbose = false) 
     end
     vHsh["fDeleteArray"] << d1    
    
    rescue => err
        puts "Exception9: #{err}"
        $LOG.error("Exception9: #{err}") 
        raise
      end # MoveToArchive(vHsh)
      
  
 
  def ChangeCtlFile(vHsh) 
   
     if vHsh["tFileId"] != ' '       
   
      query = "update ctl_file 
            set file_name = '#{vHsh["fNewVersionFileName"]}',
            ctl_status_id = #{vHsh["tNewStatus"] }   
            where ctl_file_id = #{vHsh["tFileId"]}" 
       $LOG.debug("ChangeCtlFile query #{query}")        
        stmt = @db.prepare(query)    
        stmt.execute
        stmt.finish 
      #  @db.rollback
        @db.commit           
     end
    
    rescue => err
        puts "Exception15: #{err}"
        $LOG.error("Exception16: #{err}") 
        raise
      end # ChangeStatus(vHsh)   
 
 
 
 
  
 def ShowHash(vHsh)
      
    $LOG.debug("++++++++++++++++++++++++++++++++++++++")
    $LOG.debug("fFileName #{vHsh["fFileName"]}") 
    $LOG.debug("fNewVersionFileName #{vHsh["fNewVersionFileName"]}")     
    $LOG.debug("fDgs #{vHsh["fDgs"]}")  
    $LOG.debug("fPpqId #{vHsh["fPpqId"]}")  
    $LOG.debug("tPpqId #{vHsh["tPpqId"]}")     
    $LOG.debug("fProjId #{vHsh["fProjId"]}")  
    $LOG.debug("tProjId #{vHsh["tProjId"]}") 
    $LOG.debug("tDgs #{vHsh["tDgs"]}")  
    $LOG.debug("fFileName #{vHsh["fFileName"]}")  
    $LOG.debug("tVersion #{vHsh["tVersion"]}")  
    $LOG.debug("tFileId #{vHsh["tFileId"]}")  
    $LOG.debug("tStatus #{vHsh["tStatus"]}")  
    $LOG.debug("tNewStatus #{vHsh["tNewStatus"]}")  
    $LOG.debug("++++++++++++++++++++++++++++++++++++++")
 
    rescue => err
        puts "Exception14: #{err}"
        $LOG.error("Exception14: #{err}") 
        raise
  end

      
      
   
begin

    dirLog = "I:/StoredFilesCopy/log"
    drLog = dirLog + '/' + 'log_file.log'
    $LOG = Logger.new(drLog, 'monthly') 
    $LOG.level = Logger::INFO     #  DEBUG, INFO, WARN, ERROR, FATAL
 
     puts("==============Start===========  #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} prod")
     $LOG.info("===========Start========== ") 
     $LOG.info("===========Start========== #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} prod") 
   
    @db = DBI.connect("dbi:OCI8:f409", "index_admin", "bulawayo")
   
    fileFsiArray = Array.new
    fileStartArray = Array.new
    fileWorkingXmlArray = Array.new
    fileDeleteArray = Array.new
    
 
     
     valHash = { "dirStart" => "I:/FSIZips_temp",                               #"I:/StoredFilesCopy/start", I:/FSIZips, I:/FSIZips_temp
     "dirPush" => "I:/FSIZips", 
     "dirLegacyStart" => "I:/TestzippedIIFiles",                                             #"I:/StoredFilesCopy/Legacy",
     "dirLegacyPrevious" => "I:/TestzippedIIFilesPreviousLoadFiles",             #"I:/StoredFilesCopy/LegacyPrevious",
     "dirProblemFiles" => "I:/StoredFilesCopy/Problem",
     "dirIMS" => "L:/development_lane_share/eimBI/FHD_indexing_management_system/template_1",
     #"dirIMS" => "G:/IMS/template_1",                              
     #"dirIMS" => "H:/IMS/template_1",                                                               #"I:/StoredFilesCopy/fsi_utf8_ready_test",
     "dirIMSArchive" => "X:/IMS_File_Recieve_Backup",                                      #"I:/StoredFilesCopy/fsi_utf8_store",
     "dirXml" => "I:/StoredFilesCopy/fsi_utf8_temp1",    
     "deBuggLog" => "I:/StoredFilesCopy/log", 
     "fileRecordCount" => " ",
     "tStatus" => " ",
     "tNewStatus" => " ",
     "fFileName" => " ",
     "fDgs" => " ",
     "tDgs" => " ",
     "fPpqId" => " ",
     "tPpqId" => " ",
     "fProjId" => " ",
     "tProjId" => " ",
     "tFileId" => " ",
     "fNewVersionFileName" => " ",
     "tVersion" => " ",
     "fFsiArray" => fileFsiArray,
     "fStartArray" => fileStartArray,
     "fWorkingXmlArray" => fileWorkingXmlArray,
     "fDeleteArray" => fileDeleteArray}
     
    
        
    MoveToStart(valHash)
    $LOG.info("MoveToStart completed") 
    MoveEasyLoadFiles(valHash)
    $LOG.info("MoveEasyLoadFiles completed") 
    DeleteFsiXmlFiles(valHash)
    $LOG.info("DeleteFsiXmlFiles completed") 
    UnZipFiles(valHash) 
    $LOG.info("UnZipFiles completed")     
  
    
    Dir.foreach(valHash["dirXml"])  do |x| 
    if x != "." && x != ".."
       valHash["fFileName"] = x
       valHash["fileRecordCount"] = " "
       valHash["tStatus"] = " "
       valHash["tNewStatus"] = " "
       valHash["fDgs"] = " "
       valHash["tDgs"] = " "
       valHash["fPpqId"] = " "
       valHash["tPpqId"] = " "
       valHash["fProjId"] = " "
       valHash["tProjId"] = " "
       valHash["fFileId"] = " "
       valHash["tVersion"] = " "
       valHash["fNewVersionFileName"] = " "
       valHash["fFsiArray"].clear
       valHash["fWorkingXmlArray"].clear    
         
       $LOG.info("File #{x}")
    RemoveAmp(valHash)  
       $LOG.info("RemoveAmp completed")
    GetFileDGS(valHash)   
       $LOG.info("GetFileDGS completed")    
    GetFileRecordCount(valHash)     
       $LOG.info("GetFileRecordCount completed")    
    GetFilePPQ(valHash)      
       $LOG.info("GetFilePPQ completed")

   if valHash["fileRecordCount"] == 0 
      MoveToLegacy(valHash)
        $LOG.info("MoveToLegacy completed")
            #MoveToLegacy(vHsh)
            #valHash["tPpqId"] = 'unknown'
       ShowHash(valHash)
    else
    
    GetTable(valHash) 
       $LOG.info("GetTable completed")   
    ShowHash(valHash) 
       $LOG.info("valHash[tPpqId] = #{valHash["tPpqId"]} for #{x}")  
       
       if valHash["tPpqId"] != 'unknown'
         CtlFilePropertyVersion(valHash)
            $LOG.info("CtlFilePropertyVersion completed")
         CopyToProduction(valHash) 
            $LOG.info("CopyToProduction completed")
         MoveToArchive(valHash)
            $LOG.info("MoveToArchive completed")
         ChangeCtlFile(valHash)
            $LOG.info("ChangeCtlFile completed")
        elsif
puts "indeterminate fix #{valHash["fDgs"]}" 
raise "indeterminate fix #{valHash["fDgs"]}" 
       end 
       
      end 
    end
  end
 
  DeletefArray(valHash)
   
   Dir.foreach(valHash["dirStart"])  do |x|   # Delete the files in Start directory
      if x != "." && x != ".."
      d1 = valHash["dirStart"] + '/' + x
      File.delete(d1) 
      end
   end  
   
   puts("============Finish=============#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} prod")
   $LOG.info("=========Finish ====== #{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} prod")
   
  rescue => err
        puts "Exception: #{err}"
        ShowHash(valHash)
        $LOG.error("Exception: #{err}") 
        raise
        ensure
         @db.commit
         @db.disconnect if @db 
 end
 
 