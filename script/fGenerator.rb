#!/usr/bin/ruby

class Fgenerator
  
  # main part
  # Aufruf des Programms
  # ruby fGenerator <TYP> <ANZAHL> <AUSGABE_DATEI>
  # Typ   1 = pupils erzeugen
  #       2 = courselists erzeugen
  #
  
  def main
    if ARGV[0].nil? || ARGV[1].nil? || ARGV[2].nil?
      puts "usage:\t\truby fGenerator.rb <TYP> <ANZAHL> \"<AUSGABE_DATEI>\""
      exit
    end
    
    myType = ARGV[0].to_i
    myCount = ARGV[1].to_i
    myOutput = ARGV[2]
    
    puts "Application started ..."
    
    # Datei oeffnen zufaellige Zeile nehmen und einen Datensatz generieren

    mannList = []
    frauList = []
    regionList = []
    
    # generate courselists
    if myType == 2
      i = 136 # solte am besten in eine Datei gespeichert werden
      fixturesList = []
      myCount.times do
        j = rand(101)
        #pupil = i # nachfolgend
        pupil = j # zufaellig
        course = 7
        register = "2009-01-01"
        quit = "1970-01-01"
        
        tmp = "#{i}:\n"
        tmp += "  course_id: #{course}\n"
        tmp += "  pupil_id: #{pupil}\n"
        tmp += "  register: #{register}\n"
        tmp += "  quit: #{quit}\n"
        tmp += "  canceled: false\n\n"
        fixturesList.push(tmp)
        i += 1
      end
      File.open("#{myOutput}", "w") { |f| f.puts "#{fixturesList}" }
    end
   
    # generate pupil
    if myType == 1
      # open mann.txt, read-mode and read each line
      f = File.new("mann.txt", "r") 
      f.each_line("\n") do |line|
        mannList.push(line)
      end
      f.close
      f = File.new("frau.txt", "r") 
      f.each_line("\n") do |line|
        frauList.push(line)
      end
      f.close
      f = File.new("region.txt", "r") 
      f.each_line("\n") do |line|
        regionList.push(line)
      end
      f.close
      
      # Fixtures erstellen
      fixturesList = []
      i = 1
      myCount.times do
        tmp = "f#{i}:\n"
        tmp += "  id: #{i}\n"
        gender = rand(2)
        if gender == 0
          tmp += "  firstname: #{mannList[rand(101)]}"
        else
          tmp += "  firstname: #{frauList[rand(101)]}"
        end
        tmp += "  lastname: #{regionList[rand(101)]}"
        tmp += "  phone: 0#{rand(99999999)}\n"
        tmp += "  birthday: #{1960+rand(45)}-#{1+rand(12)}-#{1+rand(28)}\n"
        tmp += "  gender: #{gender == 0}\n"
        tmp += "  flags: 0\n\n"
        fixturesList.push(tmp)
        i += 1
      end
      File.open("#{myOutput}", "w") { |f| f.puts "#{fixturesList}" }
    end
    
  puts "Application finished ..."
  end
  
end

if __FILE__ == $0
  ta = Fgenerator.new
  ta.main
end
