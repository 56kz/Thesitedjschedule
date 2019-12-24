if User.count < 2
  User.create(name: "Ivan Silva", email: "i.so@gmail.com", phone: "3168219400", rol: 1)
  Student.create(email: "i.so@gmail.com", password: "12345678")
  User.create(name: "Zorro master", email: "khris56@hotmail.com", phone: "3502633499", rol: 2)
  Student.create(email: "khris56@hotmail.com", password: "12345678")
end

if Room.count < 5
  8.times do |i|
    Room.create(name: "Cabina #{i+1}")
  end
end

if Suscription.count < 2
  Suscription.create(name: 6, status: true, hours: 3, observations: "Suscription de prueba para School", rooms: "1,2,4,8", user_id: 1)
  Suscription.create(name: 6, status: true, hours: 3, observations: "Suscription de prueba para School", rooms: "1,2,4", user_id: 2)
end

if Schedule.count < 1
   (Date.today.. Date.today+1.week).each do |d|
     block = [6, 8, 10, 12, 14, 16, 18, 20]
     block.each do |b|
       Schedule.create(day: d, hour: b, room_id: 1)
     end
   end
end

if Reservation.count < 1
  Reservation.create(schedule_id: 1, suscription_id: 1, start_hour: 8, reserve_date: '2019-12-10', room: 1)
end
