#!/usr/bin/ruby

class Fgenerator
  
  # main part
  # Aufruf des Programms
  # ruby fGenerator <TYP> <ANZAHL> <AUSGABE_DATEI>
  #
  
  def main
    if ARGV[0].nil? || ARGV[1].nil?
      puts "usage:\t\truby fixtureGen.rb 1 pupils\n\t\tfür: Einlesen von pupils.txt und Ausgabe in pupils.yml"
      puts "usage:\t\truby fixtureGen.rb 2 courses\n\t\tfür: Einlesen von courses.txt und Ausgabe in courses.yml"
      exit
    end
    
    path = "test/simpleData/"
    outPath = "test/fixtures/"
    
    type = ARGV[0].to_i
    myOutput = ARGV[1]
    
    puts "Application started ..."
    fixturesList = []
   
    # generate pupils fixture fom textfile
    if type == 1
      i = 0
      j = 0
      tmp = ""
      # open mann.txt, read-mode and read each line
      f = File.new("#{path}#{myOutput}.txt", "r") 
      
      f.each_line("\n") do |line|
        if line[0] == 35 # Wenn es ein Kommentar ist
          next
        elsif line[0] == 10 # Leere Zeile
          if j != 0
            j = 0
            fixturesList.push(tmp+"\n-------> E R R O R\n")
            i += 1
          end
          next
        else
          if j == 0
            #tmp = "p#{i}:\n"
            tmp = "FIRST_LAST:\n"
            #tmp += "  id: #{i}\n"
            tmp += "  firstname: #{line}"
            tmp['FIRST'] = line[0,line.length-1].downcase
          elsif j == 1
            tmp += "  lastname: #{line}"
            tmp['LAST'] = line[0,line.length-1].downcase
          elsif j == 2
            tmp += "  phone: #{line}"
          elsif j == 3
            tmp += "  birthday: 2000-01-01\n"
            gender = "n/a"
            if line[0] == 119
              gender = false
            elsif line[0] == 109
              gender = true
            end
            tmp += "  gender: #{gender}\n"
            tmp += "  flags: 0\n\n"
          end # elsif-Block
          j += 1
          if j >= 4
            j = 0 # zurücksetzen
            fixturesList.push(tmp)
            i += 1
          end
          
        end # großer if-elseif-else Bock
      end # alle Zeilen Schleife
      f.close
      
      File.open("#{outPath}#{myOutput}.yml", "w") { |f| f.puts "#{fixturesList}" }
    end
    
    # generate courses fixture fom textfile
    
    # Lehrer IDs
    # valentina = 1
    # igor = 2
    # vom hagen = 6
    # andabaka = 11
    
    #  id: 12
    #  name: "Gesang R6"
    #  room_id: 6
    #  coursetype: true
    #  weekday: 1
    #  start: "14:00"
    #  duration: "15:00"
    #  subject_id: 8
    #  teacher_id: 8
    
    
    if type == 2
      i = 0
      j = 0
      
      roomID = -1
      teacherID = -1
      subjectID = -1
      coursetype = -1
      weekday = -1
      modus = -1
      
      time = "n/a"
      name = "n/a"
      tmp = ""
      # open mann.txt, read-mode and read each line
      f = File.new("#{path}#{myOutput}.txt", "r") 
      
      f.each_line("\n") do |line|
        if line[0] == 35 # Wenn es ein Kommentar ist
          next
        elsif line[0] == 10 # Leere Zeile
          if j != 0
            j = 0
            fixturesList.push(tmp+"\n-------> E R R O R\n")
            i += 1
          end
          next
        elsif line[0] == 45 # Raum, Lehrer, Unterricht, Tages Information
          # "-Lehrer-Tag-Unterricht-Raum-Kurstyp-Kursname"
          # Bsp: "-6-1-1-3
          # Bsp: "-hagen-gitarre-1-keyboardRaum
          array = line.split('-')
          teacherID = array[1]
          weekday = array[2]
          subjectID = array[3]
          roomID = array[4][0,array[4].length-1]
          coursetype = -1
          #coursetype = array[5]
          #name = array[5][0,array[5].length-1]
          
        else
          if j == 0
            #tmp = "c#{i}:\n"
            tmp = "TITLE:\n"
            #tmp += "  id: #{i}\n"
            time = line[0,line.length-1]
            if time[-1] == 43 # + Zeichen, also Einzelunterricht
              time = line[0,line.length-2]
              coursetype = "true"
            else 
              coursetype = "false"
            end
            tmp += "  start: \"#{time}\"\n"
          elsif j == 1
            endTime = line[0,line.length-1]
            tmp += "  duration: \"#{endTime}\"\n"
            weekdayString = case weekday.to_i
              when 1 then "Mo"
              when 2 then "Di"
              when 3 then "Mi"
              when 4 then "Do"
              when 5 then "Fr"
              else "n/a"
            end
            tmp['TITLE'] = "#{teacherID}_#{subjectID}_#{weekdayString}_#{time[0,2]}_#{time[3,2]}"
            tmp += "  name: #{teacherID.capitalize}#{subjectID.capitalize}#{weekdayString}#{time}\n"
            tmp += "  coursetype: #{coursetype}\n"
            tmp += "  weekday: #{weekday}\n"
            tmp += "  room: #{roomID}\n"
            tmp += "  subject: #{subjectID}\n"
            tmp += "  teacher: #{teacherID}\n\n"      
          end # elsif-Block
          j += 1
          if j >= 2
            j = 0 # zurücksetzen
            fixturesList.push(tmp)
            i += 1
          end
          
        end # großer if-elseif-else Bock
      end # alle Zeilen Schleife
      f.close
      
      File.open("#{outPath}#{myOutput}.yml", "w") { |f| f.puts "#{fixturesList}" }
    end
    
    
    if type == 3
      i = 0
      course = ""
      
      tmp = ""
      # open mann.txt, read-mode and read each line
      f = File.new("#{path}#{myOutput}.txt", "r") 
      
      f.each_line("\n") do |line|
        if line[0] == 35 # Wenn es ein Kommentar ist
          next
        elsif line[0] == 10 # Leere Zeile
          next
        elsif line[0] == 45 # Minus Zeichen
          array = line.split('-')
          course = array[1]
          #course = array[0][0,array[0].length-1]
        else
          tmp = "TITLE:\n"
          tmp['TITLE'] = "#{course}_#{line[0, line.length-1]}"
          tmp += "  course: #{course}\n"
          tmp += "  pupil: #{line}"
          tmp += "  register: 2000-01-01\n"
          tmp += "  quit: 1970-01-01\n"
          tmp += "  canceled: false\n\n"    
          fixturesList.push(tmp)
          i += 1
          
        end # großer if-elseif-else Bock
      end # alle Zeilen Schleife
      f.close
      
      File.open("#{outPath}#{myOutput}.yml", "w") { |f| f.puts "#{fixturesList}" }
    end
    
    
    
    
  puts "Application finished ..."
  end
  
end

if __FILE__ == $0
  ta = Fgenerator.new
  ta.main
end
