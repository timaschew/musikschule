require "benchmark"

class RoomScheduler
  
  # Array mit internem Hash fuer alle Räume
  $rooms = []
  $rooms.push(Hash.[]("id", 1, "size", 20))
  $rooms.push(Hash.[]("id", 2, "size", 20))
  $rooms.push(Hash.[]("id", 3, "size", 20))
  $rooms.push(Hash.[]("id", 4, "size", 20))
  $rooms.push(Hash.[]("id", 5, "size", 20))
  $rooms.push(Hash.[]("id", 6, "size", 20))
  $rooms.push(Hash.[]("id", 7, "size", 20))
  $rooms.push(Hash.[]("id", 8, "size", 20))
  $rooms.push(Hash.[]("id", 9, "size", 20))
  $rooms.push(Hash.[]("id", 10, "size", 10))
  $rooms.push(Hash.[]("id", 11, "size", 20))
  $rooms.push(Hash.[]("id", 12, "size", 20))

  $courses = []
  # Array mit internem Hash für alle Kurse
  $courses.push(Hash.[]("id", 1, "size", 10))
  $courses.push(Hash.[]("id", 2, "size", 20))
  $courses.push(Hash.[]("id", 3, "size", 20))
  $courses.push(Hash.[]("id", 4, "size", 20))
  $courses.push(Hash.[]("id", 5, "size", 20))
  $courses.push(Hash.[]("id", 6, "size", 20))
  $courses.push(Hash.[]("id", 7, "size", 20))
  $courses.push(Hash.[]("id", 8, "size", 20))
  $courses.push(Hash.[]("id", 9, "size", 20))
  $courses.push(Hash.[]("id", 10, "size", 20))
  $courses.push(Hash.[]("id", 11, "size", 20))


  $courseList = []
  # Array mit Zuweisungen der Kurse zu den Räumen
  $courseList.push(Hash.[]("rid", 9, "cid", 1))
  $courseList.push(Hash.[]("rid", 2, "cid", 2))
  $courseList.push(Hash.[]("rid", 3, "cid", 3))
  $courseList.push(Hash.[]("rid", 4, "cid", 4))
  $courseList.push(Hash.[]("rid", 5, "cid", 5))
  $courseList.push(Hash.[]("rid", 6, "cid", 6))
  $courseList.push(Hash.[]("rid", 7, "cid", 1))
  $courseList.push(Hash.[]("rid", 8, "cid", 8))
  $courseList.push(Hash.[]("rid", 9, "cid", 9))
  $courseList.push(Hash.[]("rid", 10, "cid", 1))
  $courseList.push(Hash.[]("rid", 12, "cid", 11))
  
  $roomID = 12 # Raum der belegt sein soll
  
  $variante = []
  $optimal = []
  $counter = 0
  
  $diffs = $rooms.count # maximale Anzahl an Tauschvorgängen (Kurse in anderen Raum tauschen)

  def start
    puts "Raum #{@roomID} belegt!"
    puts "Vorher:"
    printf "=> ["
    
    $courseList.each do |l|
      printf "#{l['rid']}, "
    end
    puts "\n---------"
    newRoomList = $rooms.dup
    newRoomList.delete_at($roomID-1)
    $reducesRooms = newRoomList.dup
    
    
    Benchmark.bm do |x|
      x.report { searchNewTimeTable(newRoomList, 0) }
    end
    
    
    
    puts ""
    puts "optimale Variante mit #{$diffs} TauschOperationen: #{$optimal.inspect}"

    puts "fertig (#{$counter} Varianten wurden getestet)"
  end


  def searchNewTimeTable(roomList, rekCounter)
    if $diffs > 1
      if roomList.empty?
        d = checkDifference($variante)
        if d < $diffs
          $diffs = d
          $optimal = $variante
        end
        #puts "mögliche Variante: #{$variante.inspect} (#{d} Tauschverfahren)"
        $counter += 1
      else
        newRoomList = roomList.dup
        i = 0
        roomList.each do |r| 
          if roomList[i]['size'] < $courses[rekCounter]['size']
            #puts "passt nicht..."
          else
            tmp = (newRoomList.delete_at(i)['id'])
            old = $variante.dup
            $variante.push(tmp)
            result = checkDifference($variante)
            if result < $diffs
              searchNewTimeTable(newRoomList, rekCounter+1)
            end
            
            $variante = old
            newRoomList = roomList.dup
          end
          i += 1
        end
      end
    end
  end
  
  def checkDifference(newList)
    diff = 0
    newList.each_with_index do |n, i|
        if n != $courseList[i]['rid']
          diff += 1
        end
    end
    diff
  end
    
  
end

if __FILE__ == $0
  # generate an object and read the file, which name is given with the argument

  s = RoomScheduler.new
  s.start
end